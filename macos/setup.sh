#!/usr/bin/env bash
#
# macOS 개발 환경 부트스트랩
# 실행:   bash macos/setup.sh   (실행권한 없어도 동작)
# 멱등성: 여러 번 실행해도 안전하게 작성할 것
# 실행·권한 에러 대처는 README "문제 해결" 참고.
#
set -euo pipefail

log() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }

# --- 0. 사전 점검 ---------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "이 스크립트는 macOS 전용입니다." >&2
  exit 1
fi

# --- 1. Homebrew ----------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew 설치"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  log "Homebrew 이미 설치됨"
fi

# 설치 스크립트는 현재 셸의 PATH를 바꾸지 못하므로 직접 등록
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"      # Intel
fi
# 새 터미널에서도 brew를 찾도록 .zprofile에 영구 등록 (중복 방지)
if ! grep -qs 'brew shellenv' "$HOME/.zprofile"; then
  log "brew PATH를 ~/.zprofile에 추가"
  printf 'eval "$(%s shellenv)"\n' "$(command -v brew)" >> "$HOME/.zprofile"
fi

# --- 2. 패키지 설치 (Brewfile) -------------------------------------------
log "brew bundle"
brew bundle --file="$(dirname "$0")/Brewfile"

# --- 3. 언어 런타임 (mise) -----------------------------------------------
# node 등은 brew 아닌 mise로 관리. .tool-versions 의 버전을 설치
if [[ -f "$(dirname "$0")/.tool-versions" ]]; then
  log "mise install (런타임)"
  ( cd "$(dirname "$0")" && mise install )
else
  log ".tool-versions 없음 — mise install 건너뜀"
fi

# --- 4. dotfiles ----------------------------------------------------------
# starship 프롬프트를 대화형 셸에서 활성화 (중복 방지)
if command -v starship >/dev/null 2>&1; then
  if ! grep -qs 'starship init zsh' "$HOME/.zshrc"; then
    log "starship init을 ~/.zshrc에 추가"
    printf 'eval "$(starship init zsh)"\n' >> "$HOME/.zshrc"
  fi
fi
# TODO: dotfiles repo clone + 심볼릭 링크

# --- 5. VSCode 확장 -------------------------------------------------------
# 'code' 명령 필요 (VSCode: Cmd+Shift+P > Shell Command: Install 'code')
EXT_FILE="$(dirname "$0")/vscode/extensions.txt"
if command -v code >/dev/null 2>&1 && [[ -f "$EXT_FILE" ]]; then
  log "VSCode 확장 설치"
  # '#' 주석·빈 줄 무시, 각 줄 첫 토큰만 사용
  grep -vE '^\s*(#|$)' "$EXT_FILE" | awk '{print $1}' | while read -r ext; do
    [[ -n "$ext" ]] && code --install-extension "$ext" --force
  done
else
  log "code 명령 없음 — VSCode 확장 건너뜀"
fi

# --- 6. 프로젝트 공통 셋업 -----------------------------------------------
# TODO: pre-commit, git config 등

log "완료"
