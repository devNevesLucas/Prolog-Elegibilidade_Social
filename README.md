# Sistema de Análise de Benefícios Sociais em Prolog

Este projeto é um sistema especialista desenvolvido em Prolog para analisar a elegibilidade de cidadãos a diversos benefícios sociais (como Bolsa Básica, Auxílio Desemprego, etc.). O sistema considera a composição familiar, renda, patrimônio e regras regionais, oferecendo não apenas a decisão (Sim/Não), mas também uma **justificativa textual detalhada** (explicabilidade) do motivo da concessão.

## 📂 Estrutura do Projeto

O projeto é modularizado para separar dados, regras de negócio, cálculos auxiliares e a interface de explicação.

### 1. Núcleo e Carregamento
* **`principal.pl`**: Arquivo mestre. Responsável por carregar todos os módulos necessários através de diretivas `ensure_loaded/1`. É o ponto de entrada do sistema.

### 2. Base de Dados (Fatos)
* **`entrada.txt`**: Atua como o banco de dados do sistema. Contém:
    * [cite_start]**Parâmetros Normativos**: Valor do salário mínimo, coeficientes de limite de renda e limites de patrimônio[cite: 1, 6].
    * [cite_start]**Dados Regionais**: Limites específicos por município (ex: São Paulo, Curitiba, Recife)[cite: 3, 4].
    * [cite_start]**Dados das Famílias**: Estrutura familiar (`membro/2`, `familia/1`), localização e patrimônio[cite: 7, 8].
    * [cite_start]**Dados Pessoais**: Renda individual, idade, ocupação e situação de dependência[cite: 16, 18, 21].

### 3. Regras de Negócio e Cálculos

#### `familias.pl` (Agregação Familiar)
Responsável por calcular métricas agregadas da unidade familiar.
* **`renda_familiar/2`**: Soma as rendas de todos os membros.
* **`num_dependentes/2`**: Conta dependentes (com teto de 5 para fins de cálculo).
* **`renda_per_capita/2` (RPC)**: Renda bruta dividida pelo número de membros.
* **`renda_per_capita_ajustada/2` (RPCA)**: Aplica descontos baseados no número de dependentes sobre a renda bruta, favorecendo famílias numerosas.

#### `categorias.pl` (Perfil Social)
Classifica os indivíduos em categorias prioritárias.
* **`categoria_de/2`**: Define se a pessoa é `idoso`, `desempregado`, `ativo` ou `estudante` com base em idade e ocupação.
* **`categoria_mais_alta/2`**: Resolve conflitos quando uma pessoa se encaixa em múltiplas categorias (ex: um idoso desempregado é tratado prioritariamente como idoso).

#### `extensoes.pl` (Regras Auxiliares)
* **`criterio_patrimonio/2`**: Verifica se o patrimônio da família está dentro do limite permitido (calculado em múltiplos do salário mínimo).
* **`obter_limite/3`**: Busca o teto de renda permitido para um município específico. Se não houver regra regional, usa o padrão nacional.

#### `beneficios.pl` (Elegibilidade)
Contém a lógica central de "quem tem direito a quê". O predicado `tem_direito(Pessoa, Beneficio)` verifica:
1.  Vínculo familiar e regional.
2.  Cálculo da renda (Bruta ou Ajustada, dependendo do benefício).
3.  Categoria do indivíduo (ex: precisa ser idoso para Bolsa Idoso).
4.  Checagem de patrimônio e limites regionais.

Os benefícios implementados são:
* **Bolsa Básica**: Focada na renda ajustada (RPCA) e pobreza extrema.
* **Bolsa Idoso**: Para maiores de 65 anos com renda até 1 SM (variável por região).
* **Auxílio Desemprego**: Para desempregados com limite de renda flexível.
* **Auxílio Creche**: Para famílias com crianças pequenas e dependentes.
* **Bônus Monoparental**: Independente de renda, focado na estrutura familiar.

### 4. Explicabilidade (Output)

#### `explicacao.pl`
Este é o diferencial do projeto. Em vez de apenas retornar `true` ou `false`, ele gera strings formatadas explicando a decisão.
* **`motivo/3`**: Gera a frase técnica.
    * *Exemplo:* "RPCA=425.00 <= 0.5 * SM (1412.00)".
    * Usa `format/3` para interpolar os valores calculados no momento da consulta.
* **`elegibilidade/3`**: Retorna uma lista com todos os benefícios aprovados e um relatório detalhado ("Fundamentação"), incluindo a categoria prioritária do cidadão.

---

## 🚀 Como Executar

1.  Certifique-se de ter um interpretador Prolog instalado (como SWI-Prolog).
2.  Carregue o arquivo principal:
    ```prolog
    ?- [principal].
    ```

## 🧪 Exemplos de Uso

As consultas abaixo demonstram como extrair informações e relatórios do sistema.

**1. Verificar se alguém tem direito a um benefício específico:**
```prolog
?- tem_direito(tiago, auxilio_desemprego).
true.