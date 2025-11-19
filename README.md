# StormFlow — Micro‑framework de workflows/action basé sur `storm_meta`

StormFlow est un micro‑framework Ruby minimaliste conçu pour démontrer les capacités de la gem `storm_meta`: métaprogrammation, DSL d’actions, auto‑optimisation et activation conditionnelle de YJIT.

## Prérequis
- Ruby ≥ 3.2 recommandé pour YJIT moderne
- Dépendance: `storm_meta` (≥ 0.1.0)

## Installation

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
require_relative "storm_flow"
```

## Utilisation rapide
```ruby
require_relative "storm_flow"
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

## Démo
- Fichier: `demo.rb`
- Exécuter: `ruby demo.rb`

## Roadmap
- V0.2: validation typée, hooks, pipeline avant/après
- V0.3: parallélisation, bus d’événements
- V1.0: moteur stable, intégration STORM

## Licence et crédits
- StormFlow — par DALM1 (742Team)
- Dépend de `storm_meta` (MIT) — https://github.com/742Team/storm_meta# storm_flow
