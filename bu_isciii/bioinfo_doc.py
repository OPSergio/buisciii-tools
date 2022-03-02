#!/usr/bin/env python
from datetime import datetime
import logging
import rich.console
import os
import sys
import jinja2
import markdown

import bu_isciii.utils
import bu_isciii.config_json
import bu_isciii.drylab_api

log = logging.getLogger(__name__)
stderr = rich.console.Console(
    stderr=True,
    style="dim",
    highlight=False,
    force_terminal=bu_isciii.utils.rich_force_colors(),
)


class BioinfoDoc:
    def __init__(
        self,
        type=None,
        resolution_id=None,
        local_folder=None,
    ):
        if type is None:
            self.type = bu_isciii.utils.prompt_selection(
                msg="Select the documentation type you want to create",
                choices=["resolution", "delivery"],
            )
        if local_folder is None:
            self.local_folder = bu_isciii.utils.prompt_path(
                msg="Path where bioinfo folder is mounted"
            )
        else:
            self.local_folder = local_folder
        if not os.path.exists(self.local_folder):
            stderr.print("[red] Folder does not exist. " + self.local_folder + "!")
            sys.exit(1)
        if resolution_id is None:
            self.resolution_id = bu_isciii.utils.prompt_resolution_id()
        else:
            self.resolution_id = resolution_id
        self.config_doc = bu_isciii.config_json.ConfigJson().get_configuration(
            "bioinfo_doc"
        )
        conf_api = bu_isciii.config_json.ConfigJson().get_configuration("api_settings")
        rest_api = bu_isciii.drylab_api.RestServiceApi(
            conf_api["server"], conf_api["api_url"]
        )
        resolution_info = rest_api.get_request(
            "resolutionFullData", "resolution", self.resolution_id
        )
        if not resolution_info:
            stderr.print(
                "[red] Unable to fetch information for resolution "
                + self.resolution_id
                + "!"
            )
            sys.exit(1)
        resolution_folder = resolution_info["Resolutions"]["resolutionFullNumber"]
        year = str(datetime.now().year)
        self.service_folder = os.path.join(
            self.local_folder, self.config_doc["services_path"], year, resolution_folder
        )
        self.resolution = resolution_info["Resolutions"]
        self.resolution_id = resolution_info["Resolutions"]["resolutionFullNumber"]
        self.samples = resolution_info["Samples"]
        self.user_data = resolution_info["Service"]["serviceUserId"]
        self.service = resolution_info["Service"]

    def create_structure(self):
        if os.path.exists(self.service_folder):
            log.info("Already creted the service folder for %s", self.resolution_id)
            stderr.print(
                "[green] Skiping folder creation for service "
                + self.resolution_id
                + "!"
            )
            return
        else:
            log.info("Creating service folder for %s", self.resolution_id)
            stderr.print(
                "[blue] Creating the service folder for " + self.resolution_id + "!"
            )
            for folder in self.config_doc["service_folder"]:
                os.makedirs(os.path.join(self.service_folder, folder), exist_ok=True)
            log.info("Service folders created")
        return

    def create_markdown(self, file_path):
        """Create the markdown fetching the information from request api"""
        log.info(
            "starting proccess to create markdown for service %s", self.resolution_id
        )
        stderr.print("[green] Creating markdown file for " + self.resolution_id + " !")
        markdown_data = {}
        # service related information
        markdown_data["service"] = self.service
        markdown_data["user_data"] = self.user_data
        samples_in_service = {}
        for sample_data in self.samples:
            if sample_data["runName"] not in samples_in_service:
                samples_in_service[sample_data["runName"]] = {}
            if (
                sample_data["projectName"]
                not in samples_in_service[sample_data["runName"]]
            ):
                samples_in_service[sample_data["runName"]][
                    sample_data["projectName"]
                ] = []
            samples_in_service[sample_data["runName"]][
                sample_data["projectName"]
            ].append(sample_data["sampleName"])
        markdown_data["samples"] = samples_in_service

        # Resolution related information
        if "request" not in file_path:
            markdown_data["resolution"] = self.resolution
            f_name = markdown_data["resolution"]["resolutionNumber"] + ".md"
            if "resolution" in file_path:
                file_name = os.path.join(file_path, f_name)
            else:
                sub_folder = (
                    datetime.today().strftime("%Y%m%d")
                    + "_"
                    + markdown_data["service"]["serviceRequestNumber"]
                )
                file_name = os.path.join(file_path, sub_folder, f_name)
        else:
            file_name = os.path.join(
                file_path, markdown_data["service"]["serviceRequestNumber"] + ".md"
            )
        # Delivery related information

        markdown_data["service_notes"] = (
            self.service["serviceNotes"].replace("\r", "").replace("\n", " ")
        )

        template_file = self.config_doc["md_template_path_file"]
        pakage_path = os.path.dirname(os.path.realpath(__file__))
        templateLoader = jinja2.FileSystemLoader(searchpath=pakage_path)
        templateEnv = jinja2.Environment(loader=templateLoader)
        template = templateEnv.get_template(template_file)
        # Create markdown
        mk_text = template.render(markdown_data)

        with open(file_name, "wb") as fh:
            fh.write(mk_text.encode("utf-8"))

        return str(mk_text), file_name

    def convert_markdown_to_html(self, mk_text):
        html_text = markdown.markdown(
            mk_text,
            extensions=[
                "pymdownx.extra",
                "pymdownx.b64",
                "pymdownx.highlight",
                "pymdownx.emoji",
                "pymdownx.tilde",
            ],
            extension_configs={
                "pymdownx.b64": {
                    "base_path": os.path.dirname(os.path.realpath(__file__))
                },
                "pymdownx.highlight": {"noclasses": True},
            },
        )
        return html_text

    def wrap_html(self, html_text, file_name):
        file_name += ".html"
        with open(self.config_doc["html_template_path_file"], "r") as fh:
            file_read = fh.read()
        file_read = file_read.replace("{text_to_add}", html_text)
        with open(file_name, "w") as fh:
            fh.write(file_read)
        return True

    def create_service_request_doc(self):
        if not os.listdir(os.path.join(self.service_folder, "request")):
            # Create the requested service documents
            file_path = os.path.join(self.service_folder, "request")
            mk_text, file_name = self.create_markdown(file_path)
            file_name_without_ext = file_name.replace(".md", "")
            html_text = self.convert_markdown_to_html(mk_text)
            self.wrap_html(html_text, file_name_without_ext)
            self.convert_to_pdf(file_name_without_ext)
        return

    def create_resolution_doc(self):
        # check if request service documentation was created
        self.create_service_request_doc()
        file_path = os.path.join(self.service_folder, "resolution")
        mk_text, file_name = self.create_markdown(file_path)
        file_name_without_ext = file_name.replace(".md", "")
        html_text = self.convert_markdown_to_html(mk_text)
        self.wrap_html(html_text, file_name_without_ext)
        self.convert_to_pdf(file_name_without_ext)
        return

    def create_delivery_doc(self):
        # check if request service documentation was created
        self.create_service_request_doc()
        # md_name = "INFRES_" + json_data["service_number"] + ".md"

    def create_documentation(self):
        self.create_structure()
        # file_folder = os.path.join(self.service_folder, self.type)
        # file_name = os.path.join(file_folder)
        if self.type == "resolution":
            self.create_resolution_doc()
            return
        if self.type == "delivery":
            self.create_delivery()
            return
