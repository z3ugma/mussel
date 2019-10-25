from locust import HttpLocust, TaskSet, task
from random import randint,choice

import string
import random
def random_generator(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(choice(chars) for x in range(size))

class WebsiteTasks(TaskSet):
    
    @task
    def index(self):
        self.client.get("/speed")

    # @task
    # def glo(self):
    #     self.client.post("/update", data="^FET({0})^\"{1}\"".format(randint(10, 1000),random_generator(size=25)))
        

class WebsiteUser(HttpLocust):
    task_set = WebsiteTasks
    min_wait = 1000
    max_wait = 15000