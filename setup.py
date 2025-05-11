from setuptools import setup

setup(
    name="claude-cli",
    version="0.1.0",
    description="A CLI tool for interacting with Anthropic's Claude AI",
    author="Your Name",
    python_requires=">=3.7",
    install_requires=[
        "anthropic>=0.17.0",
    ],
    scripts=["claude-cli.py"],
    entry_points={
        "console_scripts": [
            "claude-cli=claude-cli:main",
        ],
    },
)