precision mediump float;

uniform sampler2D uAlbedoTexture;
uniform sampler2D uShadowTexture;
uniform mat4 uLightVPMatrix;
uniform vec3 uDirectionToLight;
uniform vec3 uCameraPosition;

varying vec2 vTexCoords;
varying vec3 vWorldNormal;
varying vec3 vWorldPosition;

void main(void) {
    vec3 worldNormal01 = normalize(vWorldNormal);
    vec3 directionToEye01 = normalize(uCameraPosition - vWorldPosition);
    vec3 reflection01 = 2.0 * dot(worldNormal01, uDirectionToLight) * worldNormal01 - uDirectionToLight;

    float lambert = max(dot(worldNormal01, uDirectionToLight), 0.0);
    float specularIntensity = pow(max(dot(reflection01, directionToEye01), 0.0), 64.0);

    vec4 texColor = texture2D(uAlbedoTexture, vTexCoords);

    // Sample the depth of the closest position to the light (depth texture)
    vec4 shadowColor = texture2D(uShadowTexture, vTexCoords);

    // Remap lightSpaceNDC.z into the 0 to 1 range and store it in a float variable called lightDepth
    float lightDepth = 0.5 * (uLightVPMatrix * vec4(vWorldPosition, 1.0)).z + 0.5;

    // Add a tiny value to eliminate surface acne
    lightDepth += 0.004;

    // Compare the depth values
    if (lightDepth > shadowColor.r) {
        // In shadow, show only ambient light color
        gl_FragColor = vec4(texColor.rgb * vec3(0.2), 1.0);
    } else {
        // Fully lit color
        vec3 ambient = vec3(0.2, 0.2, 0.2) * texColor.rgb;
        vec3 diffuseColor = texColor.rgb * lambert;
        vec3 specularColor = vec3(1.0, 1.0, 1.0) * specularIntensity;
        vec3 finalColor = ambient + diffuseColor + specularColor;
        gl_FragColor = vec4(finalColor, 1.0);
    }
}

