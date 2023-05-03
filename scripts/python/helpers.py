def remove_quotes(df, row):
    df[row] = df.explode(row)[row].astype(str).str.replace("\"", "").replace('NaN', '').groupby(level=0).agg(list)
    return df
