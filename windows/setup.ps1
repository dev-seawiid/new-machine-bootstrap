<#
  Windows 개발 환경 부트스트랩
  실행:   관리자 PowerShell 에서
            Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
            .\windows\setup.ps1
  멱등성: 여러 번 실행해도 안전하게 작성할 것
  실행·권한 에러 대처는 README "문제 해결" 참고.

  참고(WSL): 맥과 동일한 macos/setup.sh 를 재사용하려면 WSL2 설치 후 그 안에서 실행.
             WSL 설치: 관리자 PowerShell 에서  wsl --install  (재부팅 필요)
#>
$ErrorActionPreference = "Stop"

function Log($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

# --- 0. 사전 점검 ---------------------------------------------------------
if (-not $IsWindows) {
    Write-Error "이 스크립트는 Windows 전용입니다."
    exit 1
}

# --- 1. 패키지 매니저 (winget 확인) --------------------------------------
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget이 없습니다. App Installer를 먼저 설치하세요."
    exit 1
}
Log "winget 사용 가능"

# --- 2. Claude Code 설치 (부트스트랩 최소) -------------------------------
# 전략: 윈도우는 claude cli만 깐 뒤, 나머지 셋업(winget 패키지·dotfiles 등)은
#       claude 에게 대화로 시켜서 마무리한다.
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Log "Claude Code 설치"
    # 공식 PowerShell 설치 스크립트
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
} else {
    Log "Claude Code 이미 설치됨"
}

# 이후 단계는 claude 에게 위임 — 예:
#   claude "이 머신에 프론트엔드 개발 환경 세팅해줘. macos/Brewfile 참고해서
#           winget 으로 동등 패키지 설치하고 node(mise)·pnpm·vscode 확장까지"

# --- 3. 언어 런타임 (mise / scoop) ---------------------------------------
# TODO: scoop 또는 mise로 런타임 버전 관리

# --- 4. dotfiles ----------------------------------------------------------
# TODO: dotfiles repo clone + 프로필 연결

# --- 5. 프로젝트 공통 셋업 -----------------------------------------------
# TODO: pre-commit, git config 등

Log "완료"
