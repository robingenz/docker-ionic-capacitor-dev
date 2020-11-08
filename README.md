# docker-ionic-capacitor-dev

🐳 Docker image for use as [VSCode Code Remote - Container](https://code.visualstudio.com/docs/remote/containers) in [Capacitor](https://capacitorjs.com/) projects.

## How to use this image

<!-- ### Pull image

Pull from Docker Registry:  
`docker pull robingenz/ionic-capacitor-dev` -->

### Build image

Build from GitHub:  
`docker build -t https://github.com/robingenz/docker-ionic-capacitor-dev github.com/robingenz/docker-ionic-capacitor-dev`

Available build arguments:  

- JAVA_VERSION
- NODEJS_VERSION
- ANDROID_SDK_VERSION
- ANDROID_BUILD_TOOLS_VERSION
- ANDROID_PLATFORMS_VERSION
- GRADLE_VERSION
- RUBY_VERSION
- CHROME_VERSION

### Run image

Run the docker image:  
`docker run -it github.com/robingenz/docker-ionic-capacitor-dev bash`

### Use with VSCode Code Remote

`devcontainer.json`:  

```json
// For format details, see https://aka.ms/vscode-remote/devcontainer.json or this file's README at:
// https://github.com/microsoft/vscode-dev-containers/tree/v0.112.0/containers/docker-existing-dockerfile
{
    "name": "docker-ionic-capacitor-dev",
    "context": "..",
    "image": "github.com/robingenz/docker-ionic-capacitor-dev",
    "settings": {
        "terminal.integrated.shell.linux": "/bin/bash",
        "terminal.integrated.shellArgs.linux": [
            "-l"
        ]
    },
    "extensions": [],
    "forwardPorts": [
        8100,
        9876
    ]
}
```

## Security

This container is shipped with an RSA key that allows debugging through the container.
This means you won't have to accept a new RSA key on your device every time you run the container.
While convenient, it means that your device will be accessible over ADB to others who possess the key.
You can use `docker run` with `-v /your/adbkey_folder:/root/.android` to supply your own key.

## Questions / Issues

If you got any questions or problems using the image, please visit my [GitHub Repository](https://github.com/robingenz/docker-ionic-capacitor-dev) and write an issue.
