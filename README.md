# Zero-Trust Cloud Infrastructure & Web Services

Środowisko chmurowe zbudowane jako Infrastructure as Code: maszyna w Oracle Cloud,
dostęp administracyjny wyłącznie przez sieć Tailscale, usługi webowe w kontenerach
za reverse proxy Caddy z automatycznymi certyfikatami Let's Encrypt.

## Stos technologiczny

- **Chmura:** Oracle Cloud Infrastructure (instancja ARM, Always Free)
- **IaC:** Terraform (sieć VCN, Security List, instancja)
- **Konfiguracja:** Ansible (Docker, hardening systemu, Tailscale)
- **Sieć i bezpieczeństwo:** Tailscale (ACL z tagiem `tag:cloud`), UFW, fail2ban, unattended-upgrades
- **Usługi:** Docker Compose, Caddy 2
- **Frontend:** HTML5, CSS3, Vanilla JS

## Model bezpieczeństwa

1. **SSH nie jest dostępny z internetu.** Port 22 nie istnieje w OCI Security List
   (otwarte są tylko TCP 80/443, UDP 41641 dla Tailscale i ICMP 3/4 dla PMTU).
2. **Druga warstwa: UFW na hoście.** Port 22 jest dozwolony tylko na interfejsie `tailscale0`.
3. **Izolacja w sieci Tailscale.** ACL pozwala członkom tailnetu łączyć się z maszyną,
   a maszyna z tagiem `tag:cloud` nie ma reguły do inicjowania połączeń do reszty sieci.
4. **Hardening systemu** rolami `devsec.hardening` (os_hardening, ssh_hardening);
   audyt Lynis: Hardening index 77.
5. **Brak sekretów w repozytorium.** `.gitignore` wyklucza stan Terraform, `*.tfvars`,
   klucze, pliki `.env` i prawdziwy `inventory.ini`. Skan `gitleaks` nie wykrył wycieków.

Uwaga: `sshd` nasłuchuje na `0.0.0.0`; ograniczenie dostępu zapewniają warstwy 1 i 2,
a nie sam adres nasłuchu.

## Struktura repozytorium

```text
Zero-Trust-Cloud-Architecture
├── infrastructure/
│   ├── terraform/    # VCN, Security List, instancja (compute.tf, network.tf, ...)
│   └── ansible/      # docker.yml, hardening.yml, tailscale.yml, requirements.yml
├── services/
│   ├── docker-compose.yml
│   ├── Caddyfile
│   ├── cv-site/
│   └── wedding-site/
├── .gitignore
└── README.md
```

## Wdrażanie

1. **Infrastruktura**
   ```bash
   cd infrastructure/terraform
   cp terraform.tfvars.example terraform.tfvars   # uzupełnij własne wartości
   terraform init && terraform plan
   ```
   Dla już istniejącej infrastruktury użyj najpierw `import.sh` (patrz komentarze w pliku)
   i zatwierdzaj `apply` dopiero, gdy plan nie zawiera `destroy` ani `replace`.
2. **Konfiguracja systemu**
   ```bash
   cd infrastructure/ansible
   ansible-galaxy collection install -r requirements.yml
   cp inventory.ini.example inventory.ini         # uzupełnij IP Tailscale i klucz
   ansible-playbook -i inventory.ini tailscale.yml   # tylko przy nowej maszynie
   ansible-playbook -i inventory.ini docker.yml hardening.yml
   ```
3. **Usługi**
   ```bash
   cd services
   docker compose up -d
   ```

Stan Terraform, pliki `*.tfvars`, klucze SSH i klucze API nie są przechowywane w repozytorium.
