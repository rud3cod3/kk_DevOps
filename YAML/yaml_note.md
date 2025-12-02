* YAML = yaml aint markup language
* Originally : "Yer Another Markup Language"

##### Parse and  visualize yaml with python

```python
import yaml

with open('server.yaml','r') as file:
    data = yaml.safe_load(file)

print(data)
``` 
