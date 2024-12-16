# Scripts

### Run
`jupyter notebook`


### Install Requirements
`pip3 install -r requirements.txt`

If there are still missing requirements, use:

`pip3 install -r venv_requirements.txt`


### Python and venv setup
`brew install python3`

Recommended but optional - activate virtual environment:
See https://docs.python.org/3/library/venv.html

`source env/bin/activate`


### Optional - install jupyter
This *should* be captured in the requirements above, including here just in case.

```bash
pip install --upgrade pip  # Upgrade pip
pip install jupyter  # Install jupyter
```

### Packaging
To collect used dependencies and write requirements.txt:
`pipreqsnb --force`

The pipreqsnb package is a lightweight wrapper over pipreqs that includes support for Jupyter 

To collect all dependencies in this venv (used or unused):
`pip3 freeze > venv_requirements.txt`
