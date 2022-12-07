{
  description = "A flake for the chatGPT discord bot";

  outputs = { self, nixpkgs }:

    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      tls-client = with pkgs.python3Packages;
        buildPythonPackage {
          pname = "tls-client";
          version = "0.1.5";
          propagatedBuildInputs = [ ];
          src = pkgs.fetchFromGitHub
            {
              owner = "FlorianREGAZ";
              repo = "Python-TLS-Client";
              rev = "0.1.5";
              sha256 = "sha256-vfzbUdnHW3Nv+G7BH5xRCASgvbBwC+VwK40q+EEgNoQ="; # TODO
            };
        };

      OpenAIAuth = with pkgs.python3Packages;
        buildPythonPackage {
          pname = "OpenAIAuth";
          version = "0.0.3.1";
          propagatedBuildInputs = [ tls-client ];
          src = pkgs.fetchFromGitHub
            {
              owner = "acheong08";
              repo = "OpenAIAuth";
              rev = "0.0.3.1";
              sha256 = "sha256-DdgTEpW1JZJMla/a3lQi/Bc6Yib5n+2MWjAwkJF6Zys="; # TODO
            };
        };

      revChatGPT = with pkgs.python3Packages;
        buildPythonPackage {
          pname = "revChatGPT";
          version = "0.0.31.5";
          propagatedBuildInputs = [ requests OpenAIAuth ];
          src = fetchPypi {
            pname = "revChatGPT";
            version = "0.0.31.5";
            sha256 = "cdce9f63c7343411f96424abfe85bea4d94c65627f27dc7d04b5eff599032e7f"; # TODO
          };
        };

      my-python = pkgs.python3;
      python-with-my-packages = my-python.withPackages (p: with p; [
        requests
        discordpy
        revChatGPT
      ]);
    in
    {

      packages.x86_64-linux.chatGPT = with pkgs.python3Packages;
        buildPythonPackage
          rec {
            name = "chatGPT";
            src = ./.;
            propagatedBuildInputs = [ requests discordpy revChatGPT ];
          };

      containerImage =
        pkgs.dockerTools.buildImage
          {
            name = "discordgpt";
            tag = "latest";
            # created = self.lastModifiedDate;
            # contents = [ pkgs.python3 self.packages.x86_64-linux.chatGPT ];
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = [
                pkgs.dockerTools.caCertificates
                python-with-my-packages
                pkgs.bash
                self.packages.x86_64-linux.chatGPT
              ];
              pathsToLink = [ "/bin" ];
            };

            # runAsRoot = ''
            #   #!${pkgs.runtimeShell}
            #   # echo '{}' >> /bin/config.json
            # '';

            config = {
              WorkingDir = "/bin";
              Cmd = [
                "${python-with-my-packages}/bin/python"
                "/bin/ChatGPTdiscord.py"
              ];
            };
          };

      devShell.x86_64-linux = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.bashInteractive ];
        buildInputs = with pkgs; [
          nil
          nixpkgs-fmt
          python-with-my-packages
        ];
      };


    };
}
