# main.py
import os

from flask import Flask, send_file
from subprocess import Popen, PIPE, STDOUT
from selenium import webdriver
import chromedriver_binary  # Adds chromedriver binary to path

app = Flask(__name__)

# The following options are required to make headless Chrome
# work in a Docker container
#chrome_options = webdriver.ChromeOptions()
# chrome_options.add_argument("--headless")
# chrome_options.add_argument("--disable-gpu")
# chrome_options.add_argument("window-size=1024,768")
# chrome_options.add_argument("--no-sandbox")

# Initialize a new browser
#browser = webdriver.Chrome(chrome_options=chrome_options)


def log_subprocess_output(pipe):
    for line in iter(pipe.readline, b''):  # b'\n'-separated lines
        print('got line from subprocess: %r', line)


def run_test(testfile):
    process = Popen(['./run_integration_test.sh', testfile],
                    stdout=PIPE, stderr=STDOUT)
    with process.stdout:
        log_subprocess_output(process.stdout)
    exitcode = process.wait()  # 0 means success
    print('exitcode: ' + str(exitcode))
    return 'Finished!'


@app.route("/livestream")
def livestream():
    return run_test('livestream_scale_test.dart')


@app.route("/hostless")
def hostless():
    return run_test('hostless_scale_test.dart')


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
