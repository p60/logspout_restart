# logspout-restart

Docker image to restart Logspout on Docker Cloud whenever Docker Cloud's log rotation truncated the logs (which resulted 
in Logspout not logging from affected containers any more).


###Problem

[Logspout](https://github.com/gliderlabs/logspout) stops logging after truncating a logfile from a container ([#216](https://github.com/gliderlabs/logspout/issues/216)).

The [logrotate](https://github.com/tutumcloud/logrotate) service, which is built into 
[Docker Cloud](https://cloud.docker.com) runs `logrotate` with `copytruncate` and `maxsize 10M` every five minutes, so 
it truncates the logs whenever they reach 10MB.

Once a container's log reached 10MB, logspout essetialls stops logging this container, which could only be fixed by 
either restarting the container, or logspout.


###Solution

We monitor the Docker logs directory `/var/lib/docker/containers` and sum up the size of all `*.log` files in its 
subdirectories. When the overall size has been reduced since the last check, we restart the `logspout` container using
the Docker Cloud API.


###Usage

1. Add a link to the `logspout` service: 

   ```yaml
     links:
       - logspout
   ```
   Please note: We require the service to be named `logspout`.

2. Add the `global` role:

   ```yaml
     roles:
       - global
   ```

3. Link the `/var/lib/docker/containers` volume:

   ```yaml
     volumes:
       - '/var/lib/docker/containers:/var/lib/docker/containers:ro'
   ```


### Environment Variables

- `FREQ_SECS` - Seconds to wait between polling the log sizes (default: `10`)
