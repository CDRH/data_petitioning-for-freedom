def remove_quotes(df, row):
    #remove quotation marks within arrays, replace NaN values with empty strings
    # todo need to find an effective way of parsing nan and none
    df[row] = df.explode(row)[row].astype(str).str.replace("\"", "").replace('NaN', '').groupby(level=0).agg(list)
    return df
