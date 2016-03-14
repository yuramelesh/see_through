#!/usr/bin/python

import logging
import sys
import os
import json
import urllib
from gmail import Gmail
import yaml

logger = logging.getLogger(__name__)


def check_env_variables():
    if os.environ.get('GITHUB_TOKEN') is None \
            or os.environ.get('GITHUB_NOTIFIER_EMAIL') is None \
            or os.environ.get('GITHUB_NOTIFIER_EMAIL_PASSWORD') is None:
        print 'One of the environment variables is not defined.'
        print 'GITHUB_TOKEN, GITHUB_NOTIFIER_EMAIL, GITHUB_NOTIFIER_EMAIL_PASSWORD are required'

        sys.exit(1)


def read_config():
    with open("config.yml", "r") as f:
        return yaml.load(f)


def get_all_pull_requests(github_token, repo_config):
    result = urllib.urlopen(
        'https://%s:x-oauth-basic@api.github.com/repos/%s/pulls' % (github_token, repo_config['repo']))

    pull_requests_json = json.load(result.fp)

    result.close()

    return pull_requests_json


def get_pull_request(github_token, repo_config, pr_id):
    result = urllib.urlopen(
        'https://%s:x-oauth-basic@api.github.com/repos/%s/pulls/%s' % (github_token, repo_config['repo'], pr_id))

    pull_request_json = json.load(result.fp)

    result.close()

    return pull_request_json


def build_pr_status_message(github_token, repo_config):
    status = []

    pull_requests_json = get_all_pull_requests(github_token, repo_config)

    for pr in pull_requests_json:
        if pr['user']['login'] in repo_config['profiles_to_track']:
            pull_request_json = get_pull_request(github_token, repo_config, pr['number'])

            # logger.debug(json.dumps(pull_request_json, indent=4, sort_keys=True))  # pretty print

            status.append("<h3>%s</h3>" % pull_request_json['title'])
            status.append("User: %s<br/>" % pull_request_json['user']['login'])
            status.append("URL: %s<br/>" % pull_request_json['html_url'])

            if pull_request_json['mergeable']:
                color = 'green'
                has_conflicts = 'No'
            else:
                color = 'red'
                has_conflicts = 'Yes'

            status.append('Has conflicts: <div style="color: %s; display: inline; font-weight: bold;">%s</div><br/>' % (
                color, has_conflicts))
            status.append("<br/><br/>")

    return "\n".join(status)


def main():
    logging.basicConfig(level=logging.INFO, datefmt='%H:%M:%S',
                        format='%(asctime)s.%(msecs)03d [%(threadName)s] (%(name)s) %(levelname)s : %(message)s')

    check_env_variables()

    github_token = os.environ.get('GITHUB_TOKEN')
    gmail = Gmail(os.environ.get('GITHUB_NOTIFIER_EMAIL'), os.environ.get('GITHUB_NOTIFIER_EMAIL_PASSWORD'))

    config = read_config()

    for repo_config in config['github']:
        status_message = build_pr_status_message(github_token, repo_config)

        logger.debug(status_message)

        gmail.send_message(repo_config['notification_recepients'], 'PR status: %s' % repo_config['repo'],
                           status_message)

    sys.exit(0)


if __name__ == '__main__':
    main()
