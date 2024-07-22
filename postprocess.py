import sys
import pandas as pd

if __name__ == "__main__":

    # args will be forwarded to sys.argv exactly as they were in Deno, aka a list of strings
    print(sys.argv[1])

    # the very first arg will be the downloaded filename 
    df = pd.read_csv(sys.argv[1])
    df.drop('OBJECTID', axis=1, inplace=True)
    df = df.sort_values('Tribe Full Name')

    # write edited file to repo. Pandas will overwrite by default.
    df.to_csv("tribal-leaders-editted.csv",index=False)