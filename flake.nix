{
  description = "cransom flake templates";

  outputs = { self, ... }: {
    templates = {
      rust = {
        path = ./rust;
        description = "cargo/naersk, flake-parts, src_path specified ";
      };
    };
  };
}
