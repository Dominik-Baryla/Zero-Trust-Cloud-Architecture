# ☁️ Zero-Trust Cloud Infrastructure & Web Services

Zautomatyzowane środowisko chmurowe zbudowane w modelu Infrastructure as Code (IaC), hostujące odizolowane usługi webowe w bezpiecznej sieci VPN (Zero Trust). Projekt demonstruje pełen cykl życia infrastruktury: od powołania zasobów, przez hardening systemu operacyjnego, aż po wdrażanie aplikacji w kontenerach.

## 🏗️ Architektura i Stos Technologiczny

*   **Dostawca chmury:** Oracle Cloud Infrastructure (OCI) - instancje ARM/AMD.
*   **Infrastructure as Code (IaC):** Terraform.
*   **Configuration Management:** Ansible.
*   **Sieć & Bezpieczeństwo:** Tailscale (Zero Trust), UFW, Fail2Ban, rkhunter.
*   **Konteneryzacja:** Docker & Docker Compose.
*   **Reverse Proxy:** Caddy Server (automatyczne certyfikaty Let's Encrypt, wirtualne hosty).
*   **Frontend:** HTML5, CSS3 (Soft-UI/Glassmorphism), Vanilla JS (integracja z GitHub API).

## 🛡️ Bezpieczeństwo (Security-First Approach)

Środowisko zostało zaprojektowane z naciskiem na bezpieczeństwo sieciowe i systemowe:
1.  **Zero Trust Architecture:** Dostęp administracyjny (SSH) oraz interfejsy zarządzania są całkowicie odcięte od publicznego internetu. Komunikacja odbywa się wyłącznie przez zaszyfrowany tunel Tailscale.
2.  **Hardening Systemu:** Zautomatyzowany audyt bezpieczeństwa narzędziem **Lynis** wykazał wskaźnik **Hardening index: 77**, co jest wynikiem znacznie powyżej rynkowego standardu dla maszyn typu micro-instance.
3.  **Separacja Usług:** Aplikacje webowe są odizolowane w architekturze kontenerowej, a Caddy Server dba o bezbłędny routing (Virtual Hosts) na jednym publicznym adresie IP.

## 📂 Struktura Repozytorium

Projekt został zorganizowany w architekturze Monorepo, precyzyjnie oddzielając kod wdrażania infrastruktury od konfiguracji samych usług webowych:

```text
📦 Zero-Trust-Cloud-Architecture
├── 🏗️ infrastructure/           # Warstwa IaC i automatyzacji (uruchamiana lokalnie)
│   ├── ☁️ terraform/            # Skrypty powołujące wirtualne maszyny w Oracle Cloud
│   └── ⚙️ ansible/              # Playbooki: instalacja Dockera, UFW, hardening systemu
│
├── 🚀 services/                 # Środowisko produkcyjne i aplikacje (serwer WWW)
│   ├── 🐳 docker-compose.yml    # Orkestracja kontenerów dla całego ruchu sieciowego
│   ├── 🛡️ Caddyfile             # Konfiguracja Reverse Proxy, routing i certyfikaty SSL
│   ├── 👨‍💻 cv-site/              # Aplikacja SPA: interaktywne portfolio z integracją API
│   └── 💍 wedding-site/         # Dedykowany system RSVP na wydarzenie we wrześniu 2027
│
├── 🔒 .gitignore                # Zabezpieczenia zapobiegające wyciekom kluczy i .tfstate
└── 📖 README.md                 # Główna dokumentacja techniczna projektu

## ⚙️ Wdrażanie (Deployment)

1.  **Infrastruktura:** Powołanie maszyn w OCI za pomocą polecenia `terraform apply`.
2.  **Konfiguracja:** Zabezpieczenie systemu i instalacja środowiska przy użyciu `ansible-playbook`.
3.  **Usługi:** Uruchomienie aplikacji webowych i proxy komendą `docker-compose up -d` w warstwie `services/`.

*(Uwaga: Ze względów bezpieczeństwa pliki stanu .tfstate, pliki zmiennych .tfvars oraz klucze prywatne SSH zostały wykluczone z tego repozytorium).*
