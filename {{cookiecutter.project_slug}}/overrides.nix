{ assetsStatic } : self: super: {
  {{ cookiecutter.project_slug }} = self.callPackage ./. { inherit assetsStatic; };
  {{ cookiecutter.project_slug }}-dev = self.callPackage ./. {
    inherit assetsStatic;
    devDependencies = true;
  };

  django = self.django_4;
}
