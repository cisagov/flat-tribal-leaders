import sys
import pandas as pd

if __name__ == "__main__":

    # args will be forwarded to sys.argv exactly as they were in Deno, aka a list of strings

    # the very first arg will be the downloaded filename 
    df = pd.from_csv(sys.argv[0])
    df = df.drop('OBJECTID', axis=1)
    df = df.sort_values('0')

    # write edited file to repo. Pandas will overwrite by default.
    df.to_csv("tribal-leaders.csv")