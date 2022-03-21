#!/usr/bin/env python

import os
import shutil
import subprocess


def generate_blank_locale_files():
    base_locale_dir = "./backend/locale/"

    for lang in "{{ cookiecutter.language_list }}".split(","):
        os.mkdir(os.path.join(base_locale_dir, lang))
        os.mkdir(os.path.join(base_locale_dir, lang, "LC_MESSAGES"))
        open(
            os.path.join(base_locale_dir, lang, "LC_MESSAGES", "django.po"), "w"
        ).close()


def lock_poetry():
    subprocess.run(
        ["nix", "run", "nixpkgs#poetry", "--", "lock"],
        check=True,
        cwd="./backend",
    )


def lock_npm():
    subprocess.run(
        ["nix", "shell", "nixpkgs#nodejs", "-c", "npm", "i", "--package-lock-only"],
        check=True,
        cwd="./frontend",
    )

    os.mkdir("./frontend/nix")
    subprocess.run(
        [
            "nix",
            "run",
            "nixpkgs#nodePackages.node2nix",
            "--",
            "--development",
            "-l",
            "./package-lock.json",
            "-c",
            "./nix/default.nix",
            "-o",
            "./nix/node-packages.nix",
            "-e",
            "./nix/node-env.nix",
        ],
        check=True,
        cwd="./frontend",
    )


if __name__ == "__main__":
    if "{{ cookiecutter.override_user_model }}" == "n":
        shutil.rmtree("{{ cookiecutter.project_slug }}/accounts")

    generate_blank_locale_files()
    lock_poetry()
    lock_npm()

    print(
        "\n(~˘▾˘)~ Your project `{{ cookiecutter.project_slug }}` is ready, have a nice day! ~(˘▾˘~)"
    )
