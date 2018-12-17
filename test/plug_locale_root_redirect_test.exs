defmodule PlugLocaleRootRedirectTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule TestApp do
    use Plug.Router

    get "/redirection" do
      conn
      |> put_resp_header("location", "http://www.example.com/someplace-else")
      |> send_resp(301, "Redirection!")
    end

    plug(PlugLocaleRootRedirect, locales: ~w(en fr))
    plug(:match)
    plug(:dispatch)

    match _ do
      send_resp(conn, 404, "Not found")
    end
  end

  test "redirects to locale path when supported locale matches" do
    conn =
      :get
      |> conn("http://www.example.com/?foo=bar")
      |> put_req_header("accept-language", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 302
    assert get_resp_header(conn, "location") === ["http://www.example.com/fr?foo=bar"]
    assert get_resp_header(conn, "vary") === ["Accept-Language"]
  end

  test "redirects to locale path when supported locale matches without query" do
    conn =
      :get
      |> conn("http://www.example.com/?")
      |> put_req_header("accept-language", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 302
    assert get_resp_header(conn, "location") === ["http://www.example.com/fr"]
    assert get_resp_header(conn, "vary") === ["Accept-Language"]
  end

  test "redirects to locale path when supported locale matches and forwarded port" do
    conn =
      :get
      |> conn("https://www.example.com/?foo=bar")
      |> Map.put(:port, 80)
      |> put_req_header("accept-language", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4")
      |> put_req_header("x-forwarded-port", "443")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 302
    assert get_resp_header(conn, "location") === ["https://www.example.com/fr?foo=bar"]
    assert get_resp_header(conn, "vary") === ["Accept-Language"]
  end

  test "redirects to locale path when all supported locales do not match" do
    conn =
      :get
      |> conn("http://www.example.com/?foo=bar")
      |> put_req_header("accept-language", "es;q=0.4")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 302
    assert get_resp_header(conn, "location") === ["http://www.example.com/en?foo=bar"]
    assert get_resp_header(conn, "vary") === ["Accept-Language"]
  end

  test "does not redirect to locale path when request is not on root path" do
    conn =
      :get
      |> conn("http://www.example.com/some-place-fun?foo=bar")
      |> put_req_header("accept-language", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 404
    assert get_resp_header(conn, "location") == []
    assert get_resp_header(conn, "vary") == []
  end

  test "does not redirect to locale path when request is already a redirection" do
    conn =
      :get
      |> conn("http://www.example.com/redirection")
      |> put_req_header("accept-language", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4")
      |> TestApp.call(TestApp.init([]))

    assert conn.status == 301
    assert get_resp_header(conn, "location") == ["http://www.example.com/someplace-else"]
    assert get_resp_header(conn, "vary") == []
  end
end
