defmodule PlugLocaleRootRedirect do
  @moduledoc """
  """

  # Imports
  import Plug.Conn

  # Aliases
  alias Plug.Conn

  # Behaviours
  @behaviour Plug

  # Constants
  @root_path "/"
  @location_header "location"
  @vary_header "vary"
  @vary_value "Accept-Language"
  @status_code 302
  @html_template """
    <!DOCTYPE html>
    <html lang="en-US">
      <head><title>302 Found</title></head>
      <body>
        <h1>Found</h1>
        <p>The document has moved <a href="%s">here</a>.</p>
      </body>
    </html>
  """
  #
  # Types
  @type language :: {String.t, String.t, float}
  @type opts :: binary | tuple | atom | integer | float | [opts] | %{opts => opts}

  @doc """
  Initialize the plug with a list of supported locales.
  """
  @spec init(opts) :: opts
  def init(opts), do: Keyword.fetch!(opts, :locales)

  @doc """
  Call the plug.
  """
  @spec call(%Conn{}, list(atom)) :: %Conn{}
  def call(conn = %Conn{status: status, request_path: request_path}, locales) when request_path == @root_path and (is_nil(status) or (status < 300 and status >= 400)) do
    location = conn
    |> PlugBest.best_language_or_first(locales)
    |> redirect_location(conn)

    conn
    |> put_resp_header(@location_header, location)
    |> put_resp_header(@vary_header, @vary_value)
    |> send_resp(@status_code, String.replace(@html_template, "%s", location))
    |> halt
  end
  def call(conn, _), do: conn

  @spec redirect_location(language, %Conn{}) :: String.t
  defp redirect_location({_, locale, _}, conn) do
    conn
    |> request_uri
    |> URI.parse
    |> Map.put(:path, "/#{locale}")
    |> URI.to_string
  end

  @spec request_uri(%Conn{}) :: String.t
  defp request_uri(conn = %Conn{scheme: scheme, host: host, request_path: request_path, query_string: query_string}) do
    "#{scheme}://#{host}:#{canonical_port(conn)}#{request_path}?#{query_string}"
  end

  @spec canonical_port(%Conn{}) :: String.t | integer
  defp canonical_port(conn = %Conn{port: port}) do
    case get_req_header(conn, "x-forwarded-port") do
      [forwarded_port] -> forwarded_port
      [] -> port
    end
  end
end
