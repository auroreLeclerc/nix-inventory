"""UML generator"""

from io import TextIOWrapper
import subprocess
import re
import logging
from enum import Enum
from urllib import request
from pathlib import Path
from hashlib import md5
from kde_colors import MaterialColors

class PumlElement(Enum):
    """Elements in PUML"""
    ACTION = "action"
    ACTOR = "actor"
    AGENT = "agent"
    ARTIFACT = "artifact"
    BOUNDARY = "boundary"
    CARD = "card"
    CIRCLE = "circle"
    CLOUD = "cloud"
    COLLECTIONS = "collections"
    COMPONENT = "component"
    CONTROL = "control"
    DATABASE = "database"
    ENTITY = "entity"
    FILE = "file"
    FOLDER = "folder"
    FRAME = "frame"
    HEXAGON = "hexagon"
    INTERFACE = "interface"
    LABEL = "label"
    NODE = "node"
    PACKAGE = "package"
    PERSONE = "person"
    PROCESS = "process"
    QUEUE = "queue"
    RECTANGLE = "rectangle"
    STACK = "stack"
    STORAGE = "storage"
    USECASE = "usecase"

class UML():
    """Generator of UML"""
    __DIR_PATH = Path(__file__).parent
    __OUT_PATH = Path(__DIR_PATH/"inventory.puml")
    __PUML_URL = "https://github.com/plantuml/plantuml/releases/download/v1.2025.4/plantuml-gplv2-1.2025.4.jar"
    __PUML_EXEC = "/tmp/plantuml.jar"

    @property
    def __logger(self):
        logging.basicConfig(level=logging.ERROR)
        return logging.getLogger(self.__class__.__name__)

    def __get_modules(self, component_path: Path):
        modules: list[Path] = []
        with open(component_path, "r", encoding="utf-8") as file:
            for module in re.findall(r"\.{1,2}\/\S*\.\w*", file.read()):
                module_path = Path(component_path.parent/module)
                if module_path.exists():
                    modules.append(module_path)
                else:
                    if "./units/${unit}/configuration.nix" in str(module_path):
                        for unit in Path(component_path.parent/"units").iterdir():
                            modules.append(unit/"configuration.nix")
                    elif "./units/${unit}/hardware-configuration.nix" in str(module_path):
                        self.__logger.info(module_path)
                    else:
                        self.__logger.error(module_path)
        return modules

    @staticmethod
    def __md5_from(path: Path):
        return md5(str(path.resolve()).encode("utf-8")).hexdigest()

    def __discover_modules(
        self,
        file: TextIOWrapper,
        reading_dir = Path(__DIR_PATH)/".."/"modules",
        t = ""
    ):
        modules: dict[Path, list[Path]] = {}
        with open(self.__DIR_PATH/".."/".gitignore", "r", encoding="utf-8") as gitignore:
            ignores = gitignore.read().split()
            ignores.extend(["units", ".py", ".puml", ".svg", ".md", "LICENSE"])
            for module in reading_dir.iterdir():
                if not any(ignore in str(module) for ignore in ignores):
                    if module.is_file():
                        elm: PumlElement
                        match module.suffix:
                            case ".nix":
                                modules[module] = self.__get_modules(module)
                                elm = PumlElement.COMPONENT
                            case ".lock"|".json"|".yaml":
                                elm = PumlElement.COLLECTIONS
                            case _:
                                elm = PumlElement.FILE
                        file.write(f"{t}{elm.value} \"{module.name}\" as {self.__md5_from(module)}\n")
                    elif module.is_dir():
                        file.write(f"{t}{PumlElement.FOLDER.value} \"{module.name}\" {{\n")
                        modules|= self.__discover_modules(file, reading_dir/module.name, t + "   ")
                        file.write(f"{t}}}\n")
                    else:
                        raise FileExistsError(module.name)
                else:
                    self.__logger.debug(module)
        return modules


    def __init__(self):
        with open(self.__OUT_PATH, "w", encoding="utf-8") as file:
            # --- Start
            file.write("@startuml inventory\n")
            file.write("!theme amiga\n")

            # --- Component Declaration
            units: dict[Path, list[Path]] = {}
            file.write(f"{PumlElement.FOLDER.value} \"units\" {{\n")
            for unit in (Path(UML.__DIR_PATH)/".."/"units").iterdir():
                unit_configuration = unit/"configuration.nix"
                units[unit_configuration] = self.__get_modules(unit_configuration)
                file.write(f"{PumlElement.ACTOR.value} \"{unit.name}\" as {self.__md5_from(unit_configuration)}\n")
            file.write("}\n")
                
            modules = self.__discover_modules(file, Path(self.__DIR_PATH)/"..")

            # --- Relation Declaration
            colors = [
                MaterialColors.LIGHT_GREEN.value[2],
                MaterialColors.LIGHT_BLUE.value[2],
                MaterialColors.GRAY.value[2],
                MaterialColors.ORANGE.value[2],
                MaterialColors.PURPLE.value[2]
            ]
            assert len(colors) >= len(units), len(units)
            for unit, unit_modules in units.items():
                for module in unit_modules:
                    file.write(f"{self.__md5_from(unit)} -[{colors[0]}]-> {self.__md5_from(module)}\n")
                colors.pop(0)

            for module, sub_modules in modules.items():
                for sub_module in sub_modules:
                    file.write(f"{self.__md5_from(module)} --> {self.__md5_from(sub_module)}\n")
                
            
            file.write(f"{self.__md5_from(self.__DIR_PATH/".."/"flake.nix")} - {self.__md5_from(self.__DIR_PATH/".."/"flake.lock")}\n")
            file.write(f"{self.__md5_from(self.__DIR_PATH/".."/"flake.nix")} - {self.__md5_from(self.__DIR_PATH/".."/".sops.yaml")}\n")

            # --- End
            file.write("@enduml\n")

        if not Path(self.__PUML_EXEC).exists():
            request.urlretrieve(self.__PUML_URL, self.__PUML_EXEC)
        subprocess.run([
            "java", "-jar", self.__PUML_EXEC,
            "-tsvg",
            self.__OUT_PATH
        ], check=True)

UML()
