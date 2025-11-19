# StormMeta

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Helpers de métaprogrammation, JIT et auto-tuning pour des services Ruby haute performance.

## Installation

```bash
gem install storm_meta
```

ou dans votre `Gemfile`:

```ruby
gem "storm_meta", "~> 0.1.0"
```

## Utilisation rapide

```ruby
require "storm_meta"

# Activer YJIT si disponible
StormMeta::JIT.enable_yjit!(verbose: true)

# Métaprogrammation
class Room
  extend StormMeta::Meta

  dynamic_attr :name, :owner_id
  boolean_flags :archived, :locked
end

room = Room.new
room.name = "Alpha"
room.archived!
puts room.archived? # => true

# Auto-tuning
strategies = {
  ruby: ->(x) { x.to_s },
  alt:  ->(x) { "#{x}" }
}

best = StormMeta::AutoTune.pick_best(strategies, warmup_input: 123)
puts StormMeta::AutoTune.last_choice # => :ruby ou :alt

# Actions DSL
class UserActions
  extend StormMeta::Action

  action :ban_user do
    param :user_id, :integer
    step  :load_user
    step  :mark_banned
  end
end
```

## Modules

- `StormMeta::JIT` — activation YJIT en toute sécurité (`supports_yjit?`, `enable_yjit!`, `with_yjit`).
- `StormMeta::Meta` — helpers pour `dynamic_attr`, `boolean_flags`, `dsl`.
- `StormMeta::AutoTune` — benchmarke des stratégies et choisit la plus rapide.
- `StormMeta::Action` — DSL léger pour décrire et exécuter des actions.

## Exigences

- Ruby `>= 3.2.0` recommandé pour un support YJIT moderne.

## Licence

MIT — voir `LICENSE`.

## Notices

Voir `NOTICE.md` pour les avis et informations tiers éventuels.
