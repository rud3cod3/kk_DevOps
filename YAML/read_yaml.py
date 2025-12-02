import yaml

with open('server.yaml','r') as file:
    data = yaml.safe_load(file)

# print(data)
print (data["server"]["credentials"]["username"]) 
