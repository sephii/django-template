#!/usr/bin/env python

import os
import shutil
import subprocess


# FIXME remove this?
def generate_blank_locale_files():
    base_locale_dir = "./src/{{ cookiecutter.project_slug }}/locale/"

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
    # node2nix doesn’t support lockfile version 3 used by nodejs 18 so we need
    # to lock the dependencies using node 16
    subprocess.run(
        ["nix", "shell", "--impure", "nixpkgs#nodejs_16", "-c", "npm", "i", "--package-lock-only"],
        check=True,
        cwd="./src/assets",
        env={
            **os.environ,
            "NIXPKGS_ALLOW_INSECURE": "1"
        }
    )

    os.mkdir("./src/assets/nix")
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
        cwd="./src/assets",
    )


if __name__ == "__main__":
    if "{{ cookiecutter.override_user_model }}" == "n":
        shutil.rmtree("./src/{{ cookiecutter.project_slug }}/accounts")

    # generate_blank_locale_files()
    if "{{ cookiecutter.packaging }}" == "poetry":
        lock_poetry()
        use_poetry_packaging()
    elif "{{ cookiecutter.packaging }}" == "nix":
        use_nix_packaging()

    lock_npm()

    print(
        "\n(~˘▾˘)~ Your project `{{ cookiecutter.project_slug }}` is ready, have a nice day! ~(˘▾˘~)"
    )
