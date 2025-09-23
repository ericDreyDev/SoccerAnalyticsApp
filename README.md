# socceranalyticsapp

# Passo a passo para rodar o projeto:

*No celular Android:*
- Habilitar o modo desenvolvedor do android
- Habilitar depuração USB nas opções do desenvolvedor
- Habilitar instalar via USB nas opções do desenvolvedor
- No arquivo AndroidManifest.xml dentro de android/app/src/main adicionar a seguinte linha de código depois da tag manifest (linha 2):
    <uses-permission android:name="android.permission.INTERNET"/> -> obtém permissão para realizar as requisições HTTPS na api
- Conectar o celular com o pc via cabo USB-C

- Rodar os seguintes comandos na raiz do projeto:
 - flutter clean
 - flutter build apk --release
 - flutter install


*No navegador:*
- Rodar o seguinte comando para que o flutter rode o app desabilitando o CORS do navegador (por algum motivo as imagens n carregam caso contrário)
    - flutter run -d chrome --web-browser-flag "--disable-web-security


# Explicando o funcionamento do projeto:
- O objetivo do projeto era desenvolver um aplicativo que consumisse uma API externa pública ou privada e abordasse um novo tema sobre flutter não visto em aula.
- Com isso, surgiu o APP Soccer Analytics, um centralizador de informações e análises sobre as principais ligas, times e jogadores do mundo do futebol.

API Externa utilizada: [text](https://publicapi.dev/the-sports-db-api)
Novos temas Flutter: 
1. Cache local de infos críticas com flutter_secure_storage e dados simples e preferencias do usuario com shared preferences
2. Gerenciamento de estado com o pacote provider

# Estrutura do projeto:
![alt text](image.png)

Organizamos o projeto em pastas como:  
- *Components* → contendo widgets que podem ser reutilizados, tal como o componente TeamCard;  
- *Models* → contendo as classes de modelagem do sistema, nossos modelos, tais como league, match, player e team;  
- *Pages (ou views)* → são as nossas telas principais do aplicativo, tais como login, favorites, statistics;  
- *Providers* → responsável por gerenciar o estado da aplicação e conectar as services com a interface (UI), utilizando ChangeNotifier;  
- *Repositories* → contém os nossos métodos de acesso a dados da API, fazendo as requisições e retornando responses;  
- *Services* → contém comportamentos de lógica/regra de negócio da aplicação, nesse caso, a lógica de favoritos;

**Main.dart:**
- ponto de entrada da aplicação
- Inicializa com runApp()
- Injeta FavoritesProvider, usando ChangeNotifierProvider, que gerencia o estado dos favoritos em toda a aplicação
- Define a tela inicial SplashScreen

**Providers/favorites_provider:**
- Provider é uma lib flutter para gerenciamento de estado, usada pra compartilhar dados ou logica de negócio entre os widgets de forma simples, eficiente e reativa
- Atualiza a interface automaticamente sempre que os dados mudam, sem precisar do setState()
- No nosso projeto, o Provider é usado pro gerenciamento de estado da lista de favoritos

- loadFavorites() carrega a lista de favoritos salva localmente pelo service
- isFavorite(teamName) verifica se um time está marcado como favorito
- toggleFavorite(teamName) alterna o estado de favorito de um time (se estava, remove; se não, adiciona).
- removeFavorite(teamName) remove dos favoritos
- notifyListeners() atualiza automaticamente os widgets que observam esse provider, sempre que o estado muda

**pages/splash_screen.dart:**
- Essa "tela" é mais um intermediário para verificar se o usuario já está logado no app;
- Injeta o storage para acessar o método read()
- No método initState() estamos chamando o _checkAutoLogin() que vai verificar se encontra as informações do usuário no storage
- Caso encontre, chama o widget *Home* passando a liga preferida selecionada anteriormente pelo usuário
- Caso não encontre alguma informação de login, ou o campo remember-me estiver como false (não marcado), redireciona para o widget *Login*

**pages/login_page.dart:**
- Widget stateful, sendo uma tela de login da aplicação
- Injeta o storage e define as keys para armazenamento
- O método _handleLogin() é chamado ao clicar no botão de entrar, chamando outro método _saveCredentials()
- Este, por sua vez, é responsável por usar o método write() do storage para gravar as informações de login do usuário caso o checkbox esteja marcado
- Por último, chamamos a tela *ChooseLeaguePage* usando Navigator.pushReplacement que não permite voltar para a tela anterior com o botão voltar

**pages/choose_league_page.dart:**
- Widget stateful, sendo uma tela de escolha de liga preferida, na qual o usuario escolherá a liga que deseja acompanhar
- Injetamos o storage e o leagues_repository para uso dos métodos de acesso a dados de ligas
- No método initState() chamamos o método fetchLeagues() do repositório para obter as ligas disponíveis
- Nessa tela temos um DropdownButtonFormField para a seleção da liga
- Ao selecionar e clicar no botão confirmar, executa-se o método _confirmSelection()
- Esse método é responsável por gravar no storage (write()) a liga selecionada e se tudo der certo, navegar para o nosso widget *Home*

**pages/home_page.dart:**
- Widget stateful que é o painel principal do nosso aplicativo, com AppBar contendo icone logout, body contendo o card de times e footer uma NavigationBar
- NavigationBar permite navegar entre as sessões: Home, Statistics e Favorites
- IndexedStack é um widget usado para manter as seções da tela em memória. Empilha os widgets filhos mantendo o estado, e exibe com base no valor de index
- o método _logout() chamado ao clicar no Icon de Logout é responsável por deletar do storage as informações do usuário e redirecionar para o login
- o body é um IndexedStack e é dinâmico, dependendo do index selecionado vai renderizar a tela correspondente (TeamCard, StatisticsPage ou FavoritesPage)

**components/team_card.dart:**
- Widget stateful que é o componente de TeamCard usado para cada time retornado na api, na home page
- Injeta o leagues_repository para uso do método fetchTeamsByLeague() e também o FavoritesService para uso da lógica de favoritos
- Método initState() chama o fetchTeamsByLeague() e também _loadFavoriteStates()
- Este último, por sua vez, vai percorrer cada time e verificar se ele está marcado como favorito pelo método isFavorite() do service
- Alterna e exibe feedback via _toggleFavorite()
- Monta a UI do build com FutureBuilder/RefreshIndicator/GridView: [text](https://docs.flutter.dev/cookbook/lists/grid-lists)
- _buildTeamCard() renderiza cada card com logo do time, nome e botão de favorite
- Uso de CachedNetworkImage para cache de imagens da api
- Usamos um consumer do Provider de favoritos para o botão no TeamCard, adicionamos animação e feedback visual

**pages/team_statistics_page.dart:**
- Widget stateful chamado ao clicar em um TeamCard, sendo uma tela de estatísticas e informações do time selecionado
- Injeta o TeamsRepository() para uso dos metodos de acesso a dados como próxima partida, ultima partida e jogadores
- initState() vai chamar esses métodos e atribuir aos _futures correspondentes
- Métodos de refresh vão chamar os métodos do repository novamente e atualizar os _futures por meio do setState()
- _NextMatchTab e _LastMatchTab mostram um _MatchCard com dados da partida. Quando houver placar, a aba “Última” exibe o score formatado
- _PlayersTab lista todos os jogadores usando o componente _PlayerCard
- Usamos CachedNetworkImage para cache de imagens da API

**pages/favorites_page.dart:**
- Widget stateless que consiste em uma página de listagem de times favoritos
- Usamos um consumer do Provider de favoritos novamente, para que essa tela fique a par do estado dos favoritos
- E aqui usamos o ListView.builder para renderizar os times favoritos em uma lista de itens listTile