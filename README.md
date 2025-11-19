# StormFlow — Micro‑framework de workflows/action basé sur `storm_meta`

StormFlow est un micro‑framework Ruby minimaliste conçu pour démontrer les capacités de la gem `storm_meta`: métaprogrammation, DSL d’actions, auto‑optimisation et activation conditionnelle de YJIT.

## Prérequis
- Ruby ≥ 3.2 recommandé pour YJIT moderne
- Dépendance: `storm_meta` (≥ 0.1.0)

## Installation

### Ruby via rbenv (recommandé)
```bash
rbenv install 3.2.2
rbenv global 3.2.2
ruby -v
```

### Option A — Bundler (Ruby ≥ 3.2)
```ruby
# Gemfile
source "https://rubygems.org"
gem "storm_meta", "~> 0.1.0"
```
```bash
bundle install
```

### Option B — Vendor fallback (Ruby < 3.2)
```bash
git clone https://github.com/742Team/storm_meta vendor/storm_meta
```
Puis charger la librairie vendored avant StormFlow:
```ruby
$LOAD_PATH.unshift File.expand_path("vendor/storm_meta/lib", __dir__)
require "storm_meta"
require_relative "lib/storm_flow"
```

## Utilisation rapide
```ruby
require 'storm_meta'
require_relative "lib/storm_flow"
require "securerandom"

class UserFlow
  extend StormFlow

  action :register_user do
    param :name,  :string
    param :email, :string

    step :validate
    step do |ctx|
      ctx[:id] = SecureRandom.uuid
    end
    step :persist
  end

  def validate
    email = @ctx[:email]
    raise "Invalid email" unless email.include?("@")
  end

  def persist
    puts "User saved: #{@ctx[:id]} #{@ctx[:name]}"
  end
end

result = UserFlow.register_user(name: "Alice", email: "alice@example.com")
puts result.inspect
```

### Utilisation via RubyGems (gem publiée)
- Installer la gem:
```bash
gem install storm_flow
```
- Ou via Gemfile:
```ruby
gem "storm_flow", "~> 0.1.1"
```
- Code:
```ruby
require 'storm_flow'
require 'securerandom'
```

## API

### Module `StormFlow`
- `action(name, &block)`
  - Crée une `StormMeta::Action::ActionDefinition`
  - Évalue le bloc DSL via `instance_eval`
  - Stocke la définition dans `@actions`
  - Génère une méthode de classe `name` qui:
    - active YJIT via `StormMeta::JIT.enable_yjit!`
    - invoque `StormMeta::AutoTune.pick_best` pour choisir la stratégie la plus rapide
    - exécute le pipeline (`definition.call(ctx_proxy)`) et retourne le `ctx` final
- `actions` — retourne le Hash des définitions

### DSL d’action
- `param(name, type)` — typage léger (soft), non bloquant
- `step(name)` — symbole: appelle la méthode d’instance correspondante sur la classe (avec `@ctx` injecté)
- `step(&block)` — bloc: reçoit `ctx` (Hash‑like) et peut le modifier

## Exécution et performances
- JIT: `StormMeta::JIT.enable_yjit!` activé au premier appel si disponible
- Auto‑tuning: `StormMeta::AutoTune.pick_best` benchmarke les stratégies et expose `StormMeta::AutoTune.last_choice`

### Benchmarks
- Script: `bench/register.rb`
- Exemple d’exécution:
```
YJIT run: 24.073s, choice=slower
No JIT:  24.2086s, choice=fast
```
- Explication: AutoTune compare deux stratégies (`fast` et `slower`) qui exécutent toutes deux `definition.call(ctx)`. La stratégie avec le temps minimal est retenue et exposée par `last_choice`. Le support YJIT et la charge système influencent le choix.

## Démo
- Fichier: `demo.rb`
- Exécuter: `ruby demo.rb`
- Logs d'exécution (explication):
  - Les nombreuses lignes « User saved » proviennent du step `persist` qui imprime à chaque exécution.
  - `AutoTune` effectue un warmup (3 runs) et un benchmark (`iterations: 50`) pour chaque stratégie, ce qui multiplie les impressions.
  - La stratégie gagnante est exposée via `StormMeta::AutoTune.last_choice` et affichée à la fin.
- Logs attendus (extrait):
```
User saved: … Alice
AutoTune choice: fast
{:name=>"Alice", :email=>"alice@example.com", :id=>"…"}
```

### Logs d'exécution — Exemple complet
```
User saved: a190b33e-313d-4184-9981-4d10c19662f0 Alice
User saved: e52b0c7c-7568-42af-8bbb-2d275864b33e Alice
User saved: c9af0d74-d074-4775-bb49-efd7a526d7e7 Alice
User saved: e42bddbc-9169-4c98-a77b-e5eaf0e20a27 Alice
User saved: b6a8495f-78b2-434b-8dda-8710fdf6d4b6 Alice
User saved: 98a61132-712c-43ae-a4fe-5244933ab39e Alice
User saved: a588a07a-cb1d-4c27-b483-f793c1c7a93a Alice
User saved: d7cb1bdd-d18a-43d9-8975-ceb1d92df5d4 Alice
User saved: e0fe053a-749d-4951-9ec2-3959269aaed6 Alice
User saved: 16dd428c-1a8f-4284-a5d5-6ae0ae849abc Alice
User saved: 187497dc-a8a-43ed-b35e-6fc310a3d5a6 Alice
User saved: d709b1b3-4c36-45cd-ac66-a1891fa9dd4d Alice
User saved: 149c6ff2-074a-4eac-a51f-3a97fa5d9291 Alice
User saved: 5029f226-494b-4953-a62b-6da64d485b12 Alice
User saved: 562f2f8f-689f-499a-87fb-7c94fb33fec9 Alice
User saved: d39d10fd-3669-40cf-b28e-ee57070a8dbf Alice
User saved: 6b17f71e-31ad-4367-9f8a-0513509c4450 Alice
User saved: 0e36d35b-4acd-4093-b51b-07cbbe189942 Alice
User saved: c142d672-2cb2-46f8-b866-45e5a45aeacb Alice
User saved: a9547e28-8d52-4db1-9ea8-b5ea770276f4 Alice
User saved: eee7315a-757c-422a-8d64-cbed9056f898 Alice
User saved: 6bc89261-b72f-4042-a9a1-9850f92dcd2b Alice
User saved: bad54134-575c-4fd9-b7f7-5607efb816ee Alice
User saved: 5769e70c-e21f-4883-bdb3-5bc1187d7c41 Alice
User saved: e35d4ca1-745b-4259-b424-e2d003d122b8 Alice
User saved: 9bb65c43-ddd5-446a-994d-c8c0b5cd6e5b Alice
User saved: 0b40a9da-20a1-4731-bc34-311f8da6dc0a Alice
User saved: 764d45cc-714d-42f0-bf55-aa7fe899eaa8 Alice
User saved: ae1891df-831c-41e0-8395-9fc5d0b275e5 Alice
User saved: 1a63e138-4f4a-41a9-9e79-338942cf5e07 Alice
User saved: 88daa48b-fab6-4781-83af-10b7dc3c89dd Alice
User saved: 44529116-2ce3-4c5f-adbd-aceaf95aa6d3 Alice
User saved: 20defb3c-6db4-47ec-a512-a8e443209f55 Alice
User saved: 6163bdde-32b2-4ac1-b7b0-0e4c0aac7f30 Alice
User saved: 6dc22dcf-be89-4cec-a4b5-ee77ce72188a Alice
User saved: 9f382905-c400-4ff7-84b0-9e511909a5b7 Alice
User saved: a895b0da-3d7d-4ead-a328-f178081e1892 Alice
User saved: cb5ebe96-95b4-4a85-8b22-0db0a5c1ed04 Alice
User saved: e898c036-128f-4ff2-af3d-b193678cd4d9 Alice
User saved: 39c8b09f-15d1-4ad7-985c-a86096f3fbdf Alice
User saved: 55248c0d-2ab7-49c5-adc5-437a43dd994b Alice
User saved: 22ca223a-7d18-47db-a854-814c78208ab2 Alice
User saved: 3739ae67-37fe-4d6a-9bd5-c7f2eb9b209c Alice
User saved: baec60a9-cde1-4e0e-9c49-ee4a03538357 Alice
User saved: 20047e91-51ed-4f15-bf1c-44c8c362f86a Alice
User saved: 88e8d458-d309-437b-babf-8db018a318b0 Alice
User saved: 47774eaf-9dfe-4bec-879c-441911256f5d Alice
User saved: 2e00cffd-86cb-4160-9512-3847b4560f05 Alice
User saved: e7f051a7-cf30-45c9-9eb4-0cdfd00b36dc Alice
User saved: 722a5fff-7928-4b18-9743-29d8c154dd77 Alice
User saved: 4df9a466-d434-4b6b-9b44-89d3bd95011b Alice
User saved: 7fea5243-9863-4a82-b78d-d4feb68df51b Alice
User saved: 3f1f8c75-756f-43c1-a938-f2828c06ceb6 Alice
User saved: 109d422b-a853-4576-b35e-8886d3ce54cd Alice
User saved: 7a493a63-b1ca-4cda-b648-08b504b81087 Alice
User saved: 0543e0ad-2795-469c-a827-89c46b69568e Alice
User saved: 568fdd55-851e-4554-875f-4649f73ba3cb Alice
User saved: a71a0de6-2349-43d1-a031-4b7f301f0fdb Alice
User saved: b1d5e9ee-6d12-4ee8-9692-03b30692c66b Alice
User saved: b2a9e7af-36b0-46a9-9ea8-4ec986d8f194 Alice
User saved: 0ea5228b-3259-4782-8f24-3a458dfff306 Alice
User saved: ad2f1139-9b6a-4411-9806-78401dbd98b3 Alice
User saved: 2975ac2e-5520-480c-b8fe-a23338f8e26b Alice
User saved: d5899293-284b-435d-bcc4-ffc4017c9eaa Alice
User saved: 9fa61057-71da-49db-8e9c-855d40a957f3 Alice
User saved: 7af50fe6-92df-49b0-8bc3-7fc09c175d38 Alice
User saved: f478c3b0-41cb-4b43-a054-413aba199699 Alice
User saved: fed04346-9fde-418d-930b-1a6af06b0da2 Alice
User saved: a1b284cc-8967-4c89-88c0-97972af8c8cc Alice
User saved: 8b527889-b9fb-49e3-9215-ae0b57f743a1 Alice
User saved: cdfb6cca-ff9a-47cf-b2b2-0145a4dfaad1 Alice
User saved: ce38dcb7-d4cc-41e1-83aa-63cbe87c1925 Alice
User saved: 1ffdb85a-136c-4175-ac0e-b9b93e8e12f9 Alice
User saved: e584834d-1c9a-4c0c-a6fd-d4e5c959cd88 Alice
User saved: 87740929-834a-4bca-bc0d-f40ec7b29075 Alice
User saved: c480a3fc-21ff-41c4-87a7-fa0d7e6e1393 Alice
User saved: 4d9497aa-45e8-4444-865f-72a515964690 Alice
User saved: 9b2f20c4-2c02-4bc0-9081-e83ef2193a69 Alice
User saved: 98ff3c5e-c908-4302-93ee-1aec390217c8 Alice
User saved: 210cc19c-9886-4b31-89ad-73b531f5ee8a Alice
User saved: 7f455e5b-6243-4a7d-9109-e9955d1f2946 Alice
User saved: 5a26f58f-e25e-47d0-9b23-1863a9923d41 Alice
User saved: 15f502f3-fcad-446b-acfa-198af5090d83 Alice
User saved: a45d228b-5096-49ec-83a3-e587437bae79 Alice
User saved: 3fb918c6-9e10-45ce-8a1c-7b12f6b80a8a Alice
User saved: 8dfd33da-efee-4f4f-9225-3153b18798d1 Alice
User saved: 790bf6ea-f0f1-40b6-aff5-44c808679850 Alice
User saved: 65ec2132-1577-44af-90e2-d5a7fb11114c Alice
User saved: cb88f78a-bc80-4531-8e38-30f78517e205 Alice
User saved: 57f9f1a3-75b7-4b48-b606-5cfd5416a934 Alice
User saved: 04e12a79-3b7b-461a-b406-3939e7d41b4e Alice
User saved: 1e03ecdd-881b-4542-988c-67d5bc76b7b5 Alice
User saved: 1c79f5a0-1856-45b4-aa0f-84af03f9020c Alice
User saved: c03cbb60-44c8-4826-a20d-09eac286542b Alice
User saved: 9031f7d2-a1c7-4484-abe9-a94f5846b5c1 Alice
User saved: 513b0ee6-f04d-43bf-9cd4-0202abf4d894 Alice
User saved: 83305021-391c-45ac-9eda-ceed44d55936 Alice
User saved: 13f3136f-372b-48f1-a6eb-13591207c091 Alice
User saved: 05fa7cd2-aa6b-4aee-b205-22a6c1caf83e Alice
User saved: bb1d264a-b5ff-4fcf-ada2-9517ac90f290 Alice
User saved: 8d6c3f3a-c084-4948-93eb-47993f8e4a4b Alice
User saved: 4afe3d8c-e495-4138-80f0-9968786d4d90 Alice
User saved: 0ad02f87-5d2d-49f1-9bcf-c15eada3776c Alice
User saved: 7adeb898-fa46-49b0-becb-b232ddd6ddd1 Alice
User saved: 791c1906-cabe-4d17-a87a-5ff465e83029 Alice
User saved: bbb00109-30fd-4db3-bc0a-99e2fcf7936d Alice
User saved: f726948a-3c52-4c52-9ee0-4320d73876f7 Alice
AutoTune choice: fast
{:name=>"Alice", :email=>"alice@example.com", :id=>"f726948a-3c52-4c52-9ee0-4320d73876f7"}
```

### Ce qui se passe en détail
- `action :register_user` crée une définition via `StormMeta::Action::ActionDefinition`.
- La méthode de classe `register_user` active YJIT si dispo, construit un proxy `ctx` Hash‑like et délègue les steps symboliques aux méthodes d’instance avec `@ctx` injecté.
- `AutoTune.pick_best` exécute les deux stratégies (`fast`, `slower`) avec warmup + benchmark; chaque exécution déclenche `persist`, d’où la répétition des lignes.
- Une fois la meilleure stratégie choisie (`last_choice = :fast` ici), le pipeline est exécuté pour produire le `ctx` final (avec `:id`).

## Roadmap
- V0.2: validation typée, hooks, pipeline avant/après
- V0.3: parallélisation, bus d’événements
- V1.0: moteur stable, intégration STORM

## Licence et crédits
- StormFlow — par DALM1 (742Team)
- Dépend de `storm_meta` (MIT) — https://github.com/742Team/storm_meta# storm_flow
