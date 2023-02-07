from flytekit import task, workflow, Resources
from flytekitplugins.dask import Dask, Scheduler, WorkerGroup
import dask.array as da


@task(
    task_config=Dask(
        scheduler=Scheduler(
            limits=Resources(cpu="1", mem="500Mi"),
        ),
        workers=WorkerGroup(
            number_of_workers=1,
            limits=Resources(cpu="1", mem="500Mi"),
        ),
    ),
    limits=Resources(cpu="1", mem="500Mi"),
)
def dask_task() -> int:
    array = da.ones((1000, 1000, 1000))
    return int(array.mean().compute())


@workflow
def dask_workflow() -> int:
    return dask_task()


if __name__ == '__main__':
    mean_of_array = dask_workflow()
    print(f"The mean of all ones is: {mean_of_array}")
