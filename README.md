PlugLocaleRootRedirect
=================

[![Travis](https://img.shields.io/travis/remiprev/plug_locale_root_redirect.svg?style=flat-square)](https://travis-ci.org/remiprev/plug_locale_root_redirect)
[![Hex.pm](https://img.shields.io/hexpm/v/plug_locale_root_redirect.svg?style=flat-square)](https://hex.pm/packages/plug_locale_root_redirect)

`PlugLocaleRootRedirect` ensures that all requests to the root path (`/`) are
redirected to the best locale path, from a list of supported locales

Installation
------------

Add `plug_locale_root_redirect` to the `deps` function in your project's `mix.exs` file:

```elixir
defp deps do
  [
    …,
    {:plug_locale_root_redirect, "~> 0.1"}
  ]
end
```

Then run `mix do deps.get, deps.compile` inside your project's directory.

Usage
-----

`PlugLocaleRootRedirect` can be used just as any other plugs. Add
`PlugLocaleRootRedirect` before all of the other plugs you want to happen after
successful redirection to your locale path.

```elixir
defmodule Endpoint do
  plug PlugLocaleRootRedirect, locales: %w(en fr)
end
```

If a request is made to `/`, it will be redirected to `/en` or `/fr`, depending
on the request locale preference. If the request has no preference between
supported locales, it will be redirected to the first locale, `/en` in this
case.

License
-------

`PlugLocaleRootRedirect` is © 2017 [Rémi Prévost](http://exomel.com) and may be
freely distributed under the [MIT license](https://github.com/remiprev/plug_locale_root_redirect/blob/master/LICENSE.md). See the
`LICENSE.md` file for more information.
