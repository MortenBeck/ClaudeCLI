from setuptools import setup, find_packages

setup(
    name="claude-cli",
    version="0.1.0",
    description="A CLI tool for interacting with Anthropic's Claude AI",
    author="YourName",
    python_requires=">=3.7",
    install_requires=[
        "anthropic>=0.17.0",
    ],
    py_modules=["claude_cli"],
    entry_points={
        "console_scripts": [
            "claude=claude_cli:main",
        ],
    },
)