# nodecheck
Check node resource usage on SLURM cluster

![trash files](https://github.com/hengbingao/nodecheck/blob/main/png/nodecheck.png)



## **Install**

1. Clone the repository:

    ```bash
    git clone https://github.com/hengbingao/nodecheck.git
    ```

2. Set the executable permissions:

    ```bash
    cd nodecheck
    chmod +x ./bin/*
    chmod +x ./src/*
    ```

3. Add to environment:

    ```bash
    echo "export PATH=\$PATH:$(pwd)/bin" >> ~/.bashrc
    source ~/.bashrc
    ```
## **Usage**

1. help:

    ```bash
    nodecheck --help/-h
    ```
2. show the resource on node <peb(default), long, gpu, work>:

    ```bash
    nodecheck long 
    ```


