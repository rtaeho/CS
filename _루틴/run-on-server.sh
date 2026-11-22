#!/usr/bin/env bash
#
# CS 노트 자동 정리 — 오라클 인스턴스에서 cron으로 도는 실행기.
#
# 왜 서버에서 도는가: claude.ai의 클라우드 루틴이 두 번(2026-10, 2026-11-22)
# 통째로 사라졌다. GitHub 연결이 끊기면 routine과 environment가 같이 증발하고,
# 복구하려면 환경을 다시 만들고 브랜치 설정까지 고쳐야 한다. 서버에 두면 그
# 고장이 없고, 설정이 이 파일로 git에 남아 재현된다.
#
# 사용법
#   run-on-server.sh            평소 실행 (커밋·푸시까지)
#   run-on-server.sh --dry-run  글만 쓰고 커밋하지 않는다 (검증용)
#
# 전제
#   - ~/.ssh/cs_deploy : rtaeho/CS 쓰기 권한 배포키 (ssh config의 github-cs 호스트)
#   - claude 로그인됨   : claude auth status 로 확인
set -uo pipefail

REPO="$HOME/cs-notes"
LOG_DIR="$HOME/cslog-routine-logs"
RULES="_루틴/노트 작성 규칙.md"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/$(date +%Y-%m-%d).log"
exec > >(tee -a "$LOG") 2>&1

log() { echo "[$(date '+%F %T')] $*"; }

log "=== 시작 (dry-run=$DRY_RUN) ==="

cd "$REPO" || { log "레포 없음: $REPO"; exit 1; }

# 로컬에 남은 변경이 있으면 pull이 막히고 그 뒤가 전부 어긋난다. 먼저 정리한다.
if [ -n "$(git status --porcelain)" ]; then
  log "경고: 작업 트리가 깨끗하지 않다. 이전 실행이 중간에 끊겼을 수 있다."
  git status --short | head -10
  git reset --hard -q HEAD
  git clean -fdq
  log "되돌렸다."
fi

git fetch -q origin master && git checkout -q master && git pull -q --ff-only origin master || {
  log "pull 실패 — 중단한다."; exit 1
}
BEFORE=$(git rev-parse HEAD)
log "최신 상태: ${BEFORE:0:7}"

[ -f "$RULES" ] || { log "규칙 파일이 없다: $RULES — 아무것도 쓰지 않고 중단한다."; exit 1; }

# 규칙 본문은 레포 파일에 있다. 프롬프트는 그 파일을 가리키는 짧은 포인터로 둔다.
# (프롬프트에 규칙을 직접 넣으면 고칠 때마다 긴 한글을 다시 밀어넣어야 하고 깨진다)
PROMPT=$(cat <<'PROMPT_EOF'
CS 레포의 자동 노트 정리 루틴이다. 현재 디렉토리가 레포 루트다.

1. `_루틴/노트 작성 규칙.md` 파일을 읽는다. 파일명에 공백이 있으니 반드시 따옴표로 감싼다.
2. 그 파일에 적힌 내용을 그대로 수행한다. 1부(AI 소식)와 2부(개념 노트) 모두 해당한다.
3. 그 파일을 읽지 못하면 아무것도 쓰지 말고 그 사실을 보고하고 끝낸다. 추측으로 글을 쓰지 않는다.

git 중 **읽기 명령은 써도 된다** — status, log, diff, show. 규칙 파일의 2부 중복
판정이 `git log -p`로 체크박스 전환을 보므로 이게 필요하다. 레포는 이미 최신 상태다.

git 중 **쓰기 명령은 하지 않는다** — commit, push, add, checkout, reset, merge, branch.
커밋과 푸시는 이 스크립트가 한다. 파일을 쓰고 고치는 것까지만 하면 된다.

마지막에 무엇을 썼는지 한 줄로 요약해라.
PROMPT_EOF
)

log "Claude 실행 중…"
claude -p "$PROMPT" \
  --allowedTools "Bash,Read,Write,Edit,Glob,Grep,WebFetch,WebSearch" \
  --permission-mode acceptEdits \
  2>&1 | sed 's/^/    /'
STATUS=${PIPESTATUS[0]}
log "Claude 종료 코드: $STATUS"

CHANGED=$(git status --porcelain | wc -l | tr -d ' ')
log "변경된 파일: ${CHANGED}개"
[ "$CHANGED" -eq 0 ] && { log "쓴 글이 없다. 커밋하지 않는다."; exit 0; }
git status --short | sed 's/^/    /'

if [ "$DRY_RUN" -eq 1 ]; then
  log "dry-run이므로 커밋하지 않는다. 되돌리려면: cd $REPO && git reset --hard && git clean -fd"
  exit 0
fi

# 커밋 메시지는 새로 생긴 노트 제목에서 만든다.
NEW_NOTES=$(git status --porcelain | awk '$1=="??"{ $1=""; print }' | sed 's|.*/||; s|\.md$||' | sed 's/^ *//' | head -2 | paste -sd ',' - | sed 's/,/와 /')
MSG="docs: ${NEW_NOTES:-노트} 정리"

git add -A
# author를 고정하지 않으면 GitHub 기여 그래프에 반영되지 않는다.
git -c user.name="rtaeho" -c user.email="ryou0920@naver.com" commit -q -m "$MSG" || {
  log "커밋 실패"; exit 1
}
log "커밋: $(git log --oneline -1)"

git push -q origin master || { log "푸시 실패"; exit 1; }
log "푸시 완료 — webhook이 블로그에 반영한다"
log "=== 끝 ==="
