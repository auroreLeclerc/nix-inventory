"""UML generator"""

from io import TextIOWrapper
import subprocess
import re
import logging
import json
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
    __PUML_URL = "https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar"
    __PUML_EXEC = "/tmp/plantuml.jar"

    @property
    def __logger(self):
        logging.basicConfig(level=logging.WARNING)
        return logging.getLogger(self.__class__.__name__)

    def __get_modules(self, component_path: Path):
        modules: list[Path] = []
        with open(component_path, "r", encoding="utf-8") as file:
            for module in re.findall(r"\.{1,2}/[^\s(){}$;]+\.\w{2,4}", file.read()):
                module_path = Path(component_path.parent/module)
                if str(component_path).endswith("flake.nix") and str(module_path).endswith("ryubing-canary.nix"):
                    continue
                if module_path.exists():
                    modules.append(module_path)
                else:
                    if "./units/${unit}/configuration.nix" in str(module_path):
                        for unit in Path(component_path.parent/"units").iterdir():
                            modules.append(unit/"configuration.nix")
                    elif "${unit}" in str(module_path) or "${name}" in str(module_path):
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
        reading_dir = Path(__DIR_PATH)/"..",
        t = ""
    ):
        modules: dict[Path, list[Path]] = {}
        with open(self.__DIR_PATH/".."/".gitignore", "r", encoding="utf-8") as gitignore:
            ignores = gitignore.read().split()
            ignores.extend(["units", "utilities", ".puml", ".svg", ".md", "LICENSE", ".shellcheckrc", ".pre-commit-config.yaml", ".git"])
            for module in reading_dir.iterdir():
                self.__logger.info(module.resolve())
                if not any(ignore in str(module.resolve()) for ignore in ignores):
                    if module.is_file():
                        elm: PumlElement
                        match module.suffix:
                            case ".nix":
                                modules[module] = self.__get_modules(module)
                                elm = PumlElement.COMPONENT
                            case ".lock"|".json"|".yml"|".yaml"|".toml":
                                elm = PumlElement.COLLECTIONS
                            case ".sql":
                                elm = PumlElement.DATABASE
                            case ".sh":
                                elm = PumlElement.ARTIFACT
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

    def __discover_flakes(
        self,
        file: TextIOWrapper,
        reading_file = Path(__DIR_PATH)/".."/"flake.lock",
        t = ""
    ):
        inputs: list[str] = []
        with open(reading_file, "r", encoding="utf-8") as flake:
            flakes = json.load(flake)
            for key in flakes["nodes"]["root"]["inputs"]:
                file.write(f"{t}{PumlElement.CLOUD.value} \"{key}\" as {md5(key.encode("utf-8")).hexdigest()}\n")
                inputs.append(key)
        return inputs

    def __init__(self):
        with open(self.__OUT_PATH, "w", encoding="utf-8") as file:
            def give_me_colors(units_number: int):
                colors = [
                    MaterialColors.LIIME.value[6],
                    MaterialColors.PINK.value[6],
                    MaterialColors.PURPLE.value[6],
                    MaterialColors.BLUE.value[6],
                    MaterialColors.GREEN.value[6],
                    MaterialColors.ORANGE.value[6],
                    MaterialColors.BROWN.value[6],
                ]
                assert len(colors) >= units_number, units_number
                return colors

            # --- Start
            file.write("@startuml inventory\n")
            file.write("!theme crt-amber\n")

            # --- Component Declaration
            units: dict[Path, list[Path]] = {}
            colors = give_me_colors(len(units))
            file.write(f"{PumlElement.FOLDER.value} \"units\" {{\n")
            for unit in (Path(UML.__DIR_PATH)/".."/"units").iterdir():
                unit_configuration = unit/"configuration.nix"
                units[unit_configuration] = self.__get_modules(unit_configuration)
                file.write(f"{PumlElement.ACTOR.value} \"{unit.name}\" as {self.__md5_from(unit_configuration)} {colors[0]}\n")
                colors.pop(0)
            file.write("}\n")
                
            flakes = self.__discover_flakes(file)
            modules = self.__discover_modules(file)

            # --- Relation Declaration
            file.write(f"{self.__md5_from(self.__DIR_PATH/".."/"flake.nix")} - {self.__md5_from(self.__DIR_PATH/".."/"flake.lock")}\n")
            file.write(f"{self.__md5_from(self.__DIR_PATH/".."/"flake.nix")} - {self.__md5_from(self.__DIR_PATH/".."/".sops.yaml")}\n")

            for flake in flakes:
                file.write(f"{md5(flake.encode("utf-8")).hexdigest()} --> {self.__md5_from(self.__DIR_PATH/".."/"flake.lock")}\n")

            colors = give_me_colors(len(units))
            for unit, unit_modules in units.items():
                file.write(f"{self.__md5_from(self.__DIR_PATH/".."/"flake.nix")} -[{colors[0]}]-> {self.__md5_from(unit)}\n")
                for module in unit_modules:
                    file.write(f"{self.__md5_from(unit)} <-[{colors[0]}]- {self.__md5_from(module)}\n")
                colors.pop(0)

            for module, sub_modules in modules.items():
                for sub_module in sub_modules:
                    file.write(f"{self.__md5_from(module)} <-- {self.__md5_from(sub_module)}\n")

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
