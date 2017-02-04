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

    plug PlugLocaleRootRedirect, locales: ~w(en fr)
    plug :match
    plug :dispatch

    match _ do
      conn |> send_resp(404, "Not found")
    end
  end

  defp get(path_and_query_string, accept_language_header) do
    uri = URI.parse("http://www.example.com#{path_and_query_string}")

    conn(:get, uri)
    |> put_req_header("accept-language", accept_language_header)
    |> TestApp.call(TestApp.init([]))
  end

  test "redirects to locale path when supported locale matches" do
    conn = get("/?foo=bar", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4")

    assert conn.status == 302
    assert get_resp_header(conn, "location") === ["http://www.example.com/fr?foo=bar"]
  end

  test "redirects to locale path when all supported locales do not match" do
    conn = get("/?foo=bar", "es;q=0.4")

    assert conn.status == 302
    assert get_resp_header(conn, "location") === ["http://www.example.com/en?foo=bar"]
  end

  test "does not redirect to locale path when request is not on root path" do
    conn = get("/some-place-fun?foo=bar", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4")

    assert conn.status == 404
    assert get_resp_header(conn, "location") == []
  end

  test "does not redirect to locale path when request is already a redirection" do
    conn = get("/redirection", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4")

    assert conn.status == 301
    assert get_resp_header(conn, "location") == ["http://www.example.com/someplace-else"]
  end
end
