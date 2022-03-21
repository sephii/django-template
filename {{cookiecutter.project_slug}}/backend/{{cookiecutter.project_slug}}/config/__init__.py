import glob
import os


def get_project_root_path():
    """
    Return the absolute path to the root of the project.
    """
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
