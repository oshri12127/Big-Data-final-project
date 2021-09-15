{
  "nbformat": 4,
  "nbformat_minor": 0,
  "metadata": {
    "colab": {
      "name": "Untitled3.r",
      "provenance": [],
      "authorship_tag": "ABX9TyOqNOISQ2XAuI2eDuodwlop",
      "include_colab_link": true
    },
    "kernelspec": {
      "name": "ir",
      "display_name": "R"
    },
    "language_info": {
      "name": "R"
    }
  },
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "view-in-github",
        "colab_type": "text"
      },
      "source": [
        "<a href=\"https://colab.research.google.com/github/oshri12127/Big-Data-final-project/blob/main/project.R\" target=\"_parent\"><img src=\"https://colab.research.google.com/assets/colab-badge.svg\" alt=\"Open In Colab\"/></a>"
      ]
    },
    {
      "cell_type": "code",
      "metadata": {
        "id": "HHr2xS8RJmBv"
      },
      "source": [
        "install.packages(\"googledrive\")\n",
        "install.packages(\"httpuv\") \n",
        "library(\"googledrive\") \n",
        "library(\"httpuv\")"
      ],
      "execution_count": 7,
      "outputs": []
    },
    {
      "cell_type": "code",
      "metadata": {
        "id": "Pvj67RvWMRBB"
      },
      "source": [
        "if (file.exists(\"/usr/local/lib/python3.7/dist-packages/google/colab/_ipython.py\")) \n",
        "{\n",
        "  install.packages(\"R.utils\")\n",
        "  library(\"R.utils\")\n",
        "  library(\"httr\")\n",
        "  my_check <- function() {return(TRUE)}\n",
        "  reassignInPackage(\"is_interactive\", pkgName = \"httr\", my_check) \n",
        "  options(rlang_interactive=TRUE)\n",
        "}"
      ],
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "code",
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "6fueDg85MdJk",
        "outputId": "446a40d9-7ac0-4d22-81bb-be8c4defae73"
      },
      "source": [
        "drive_auth(use_oob = TRUE, cache = FALSE)"
      ],
      "execution_count": null,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stderr",
          "text": [
            "Please point your browser to the following url: \n",
            "\n",
            "https://accounts.google.com/o/oauth2/auth?client_id=603366585132-dpeg5tt0et3go5of2374d83ifevk5086.apps.googleusercontent.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code\n",
            "\n"
          ]
        }
      ]
    }
  ]
}