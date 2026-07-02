# 🚀 new-machine-bootstrap

> 새 장비(macOS / Windows)를 받았을 때, **명령어 한 줄로** 개발 환경을 셋업하는 부트스트랩 스크립트.

아무것도 설치되지 않은 새 장비 — git도 없고 브라우저만 있는 환경 — 을 기준으로 만들었다.

- ✅ ZIP만 받아서 바로 실행 (git 불필요)
- ✅ 멱등성 — 여러 번 돌려도 안전
- ✅ 패키지 추가 = 목록 파일 한 줄 수정 (스크립트 로직은 안 건드림)

---

## 📦 무엇이 설치되나

| 분류       | 항목                                                                    |
| ---------- | ----------------------------------------------------------------------- |
| **런타임** | node (mise로 버전 고정), pnpm                                           |
| **CLI**    | git, gh, ripgrep, fd, fzf, jq, bat, eza, zoxide, tree                   |
| **셸**     | starship, zsh-autosuggestions, zsh-syntax-highlighting, atuin, tealdeer |
| **AI**     | claude-code, claude, openusage                                          |
| **에디터** | VSCode + 확장 일괄 설치                                                 |
| **GUI**    | cmux, chrome, raycast, obsidian, rectangle, figma, bruno, docker 등     |

> 전체 목록·역할은 [`macos/Brewfile`](macos/Brewfile), [`macos/vscode/extensions.txt`](macos/vscode/extensions.txt) 참고.

---

## ⚡ 빠른 시작 (git 없는 새 장비 기준)

### 1. 소스 내려받기

GitHub repo 페이지 → **`Code` ▸ `Download ZIP`** → 다운로드 폴더에 `new-machine-bootstrap-main.zip` 저장.

### 2. 압축 풀고 실행

<details open>
<summary><b>🍎 macOS</b></summary>

```bash
cd ~/Downloads
unzip new-machine-bootstrap-main.zip      # Finder 더블클릭으로 풀어도 됨
cd new-machine-bootstrap-main

bash macos/setup.sh                        # 실행권한 없어도 동작 (chmod 불필요)
```

</details>

<details>
<summary><b>🪟 Windows</b></summary>

```powershell
cd $HOME\Downloads
Expand-Archive .\new-machine-bootstrap-main.zip -DestinationPath .   # 탐색기 우클릭 '압축 풀기'도 가능
cd .\new-machine-bootstrap-main

# 관리자 PowerShell 에서:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\windows\setup.ps1
```

전략: **claude cli 만 설치한 뒤, 나머지 셋업은 claude 에게 위임**한다.

</details>

> 에러가 나면 → [문제 해결](#-문제-해결)

### 3. (이후) git 생기면 클론으로 전환

`setup.sh` 가 git 을 깔아주므로, 다음부턴 ZIP 대신 클론해서 관리한다.

```bash
git clone <이 repo URL> ~/Projects/new-machine-bootstrap
```

---

## 🛠 문제 해결

<details>
<summary><b>🍎 macOS (<code>setup.sh</code>)</b></summary>

| 증상                                  | 원인                         | 해결                                                           |
| ------------------------------------- | ---------------------------- | -------------------------------------------------------------- |
| `permission denied: ./macos/setup.sh` | 실행권한 없음                | `bash macos/setup.sh` 로 실행 (또는 `chmod +x macos/setup.sh`) |
| `+x` 줘도 `permission denied`         | noexec 위치·경로 문제        | `bash macos/setup.sh` 로 직접 실행                             |
| `bad interpreter` / 이상한 에러       | 윈도우 줄바꿈(CRLF)          | `sed -i '' 's/\r$//' macos/setup.sh` 로 LF 변환                |
| `operation not permitted`             | macOS 보안(전체 디스크 접근) | 시스템설정 ▸ 개인정보보호 ▸ 전체 디스크 접근 → 터미널 허용     |
| 다운로드 파일 "차단됨(quarantine)"    | Gatekeeper                   | `xattr -d com.apple.quarantine macos/setup.sh`                 |

> ⚠️ `sudo` 는 꼭 필요한 경우 아니면 쓰지 말 것 (Homebrew 는 sudo 금지).

</details>

<details>
<summary><b>🪟 Windows (<code>setup.ps1</code>)</b></summary>

| 증상                                           | 원인                 | 해결                                                             |
| ---------------------------------------------- | -------------------- | ---------------------------------------------------------------- |
| `running scripts is disabled on this system`   | 실행 정책 차단       | `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`     |
| `is not digitally signed` / UnauthorizedAccess | 서명 안 됨           | 위 Bypass, 또는 `Unblock-File .\windows\setup.ps1`               |
| 받은 파일이 "차단됨(Mark of the Web)"          | 인터넷 출처 표시     | 파일 속성 ▸ '차단 해제', 또는 `Unblock-File <경로>`              |
| `Access is denied`                             | 관리자 권한 필요     | PowerShell 을 '관리자 권한으로 실행'                             |
| `winget : ... 인식되지 않습니다`               | App Installer 미설치 | MS Store 에서 'App Installer' 설치 후 재시도                     |
| PowerShell 5 vs 7 동작 차이                    | 구버전 셸            | PowerShell 7(`pwsh`) 사용: `winget install Microsoft.PowerShell` |

</details>

---

## 📂 구조

```
new-machine-bootstrap/
├─ README.md
├─ macos/
│  ├─ setup.sh             # brew → mise(node) → VSCode 확장
│  ├─ Brewfile             # CLI·GUI·AI 툴 목록
│  ├─ .tool-versions       # 런타임 버전 고정 (mise)
│  └─ vscode/extensions.txt
└─ windows/setup.ps1       # claude cli 설치 + 위임 전략
```

---

## 🧩 커스터마이즈

- **패키지 추가/삭제** → [`macos/Brewfile`](macos/Brewfile) 한 줄 수정
- **VSCode 확장** → [`macos/vscode/extensions.txt`](macos/vscode/extensions.txt) 수정 (`#` 주석·빈 줄은 무시됨)
- **node 등 런타임 버전** → [`macos/.tool-versions`](macos/.tool-versions) 에서 팀 프로젝트 버전에 맞춤
- 현재 환경을 그대로 추출하려면: `brew bundle dump --file=macos/Brewfile --force`
