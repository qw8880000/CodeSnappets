# -*- coding:cp936 -*-

import sys
import subprocess
import json

def fetch(kbids=[]):
    output = subprocess.check_output('wmic qfe get hotfixid, installedon')
    # logging.debug(output)

    result = []
    output_list = (output.split())[2:]
    for i in range(0, len(output_list), 2):
        hotfixid = output_list[i]
        installedon = output_list[i + 1]
        pair = {"hotFixID":hotfixid, "installedOn":installedon}
        # logging.debug(pair)

        if not kbids:
            result.append(pair)
            # logging.debug(result)
        elif kbids and hotfixid in kbids:
            result = pair
            # logging.debug(result)
            break

    return json.dumps(result)


if __name__ == '__main__':
    kbids = sys.argv[1:] if len(sys.argv) > 0 else []
    # logging.debug(kbids)
    result = fetch(kbids)
    print(result)
