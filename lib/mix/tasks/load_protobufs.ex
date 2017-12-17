defmodule Mix.Tasks.LoadProtobufs do
  def run(_) do
    module_name = Module.concat("LoadProtobufs", Macro.camelize("Proto"))
    content = quote do
      use Protobuf, from: Path.wildcard(Path.expand("../../../../messages/*.proto", __DIR__))
    end

    Module.create(module_name, content, Macro.Env.location(__ENV__))
  end
end
