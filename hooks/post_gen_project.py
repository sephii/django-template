#!/usr/bin/env python

import os
import shutil
import subprocess


def lock_poetry():
    subprocess.run(
        ["nix", "run", "nixpkgs#poetry", "--", "lock"],
        check=True,
        cwd="./src",
    )


def use_poetry_packaging():
    os.rename("./default_poetry.nix", "./default.nix")
    os.unlink("./default_nix.nix")
    os.unlink("./requirements.nix")
    os.unlink("./requirements_dev.nix")


def use_nix_packaging():
    os.rename("./default_nix.nix", "./default.nix")
    os.unlink("./default_poetry.nix")


def lock_npm():
    subprocess.run(
        [
            "nix",
            "shell",
            "--impure",
            "nixpkgs#nodejs_20",
            "-c",
            "npm",
            "i",
            "--package-lock-only",
        ],
        check=True,
        cwd="./src/assets",
        env={**os.environ, "NIXPKGS_ALLOW_INSECURE": "1"},
    )

    os.mkdir("./src/assets/nix")


if __name__ == "__main__":
    if "{{ cookiecutter.override_user_model }}" == "n":
        shutil.rmtree("./src/{{ cookiecutter.project_slug }}/accounts")

    if "{{ cookiecutter.packaging }}" == "poetry":
        lock_poetry()
        use_poetry_packaging()
    elif "{{ cookiecutter.packaging }}" == "nix":
        use_nix_packaging()

    lock_npm()

    print(
        "\n(~˘▾˘)~ Your project `{{ cookiecutter.project_slug }}` is ready, have a nice day! ~(˘▾˘~)"
    )
