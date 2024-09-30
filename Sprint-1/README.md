##   Sprint 1 - Scrum Agile e Linux completo + servidores

<p>

 Nesta sprint, aprendi sobre a metodologia Scrum e seu funcionamento na prática. Além disso, adquiri conhecimentos fundamentais sobre o sistema Linux, redes de computadores e servidores Linux.
 
  Antes de iniciar a trilha, meu conhecimento sobre Linux era bastante superficial. Nesta primeira sprint, aprendi sobre o Kernel Linux, distribuições, conexões em modo bridge, NAT e interno, como conectar remotamente por SSH, conceitos importantes sobre licenças copyleft x permissivas, e muito mais.

 Também aprendi comandos essenciais no terminal. Para praticar, utilizei as distros Debian, Ubuntu, Mint e CentOS. Optei por usar uma distribuição baseada no RedHat, para não ficar limitado apenas ao ecossistema Debian.


 </p>

 #### Comandos básicos do terminal que são úteis.
- pwd: mostra o diretório atual.
- cd: muda o diretório.
- cd ..: volta ao diretório anterior.
- ls: exibe todas as pastas visíveis em um diretório.
- ls -a: exibe todas as pastas, visíveis e ocultas, em um diretório.
- sudo su: transforma o usuário em root.
- apt install: instala um software específico.
- apt remove --purge: remove um programa e suas configurações com o --purge.
- mkdir nome-da-pasta: cria uma pasta em um local específico.
  
Esses são só alguns dos comandos e conceitos que aprendi ao longo da Sprint 1.

Além disso, aprendi sobre protocolos TCP / IP, UDP, DHCP, Métodos Get / Post entre outros conhecimentos de redes...

Exemplo de problema que precisei resolver:
Estava querendo conectar na VM ubuntu por ssh, porém diversos erros estavam surgindo no caminho, foi nesse momento que entendi melhor sobre a importancia do apt upgrade, systemctl start ssh, systemctl status ssh, nano /etc/ssh/sshd_config e adicionar o comando " PermitRootLogin Yes ", com a ajuda do ChatGPT consegui resolver esse problema que foi essencial para o desenvolvimento da minha confiança e aprendizado!
