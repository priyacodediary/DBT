{% set fruits=["apple","banana","cherry"] %}
{% for i in fruits %}
    {% if i!="cherry" %}
         {{ i }}
    {% else %}
         {{ i }} is the last fruit  
    {% endif %}
{% endfor %}