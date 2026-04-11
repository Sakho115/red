export const HardwarePreviewHook = {
    async mounted() {
        const fileUrl = this.el.dataset.fileUrl;
        const fileType = this.el.dataset.fileType;

        if (fileType !== "stl") return;

        try {
            // Dynamically load Three.js and STLLoader
            const THREE = await import('https://cdn.skypack.dev/three@0.132.2');
            const { STLLoader } = await import('https://cdn.skypack.dev/three@0.132.2/examples/jsm/loaders/STLLoader.js');
            const { OrbitControls } = await import('https://cdn.skypack.dev/three@0.132.2/examples/jsm/controls/OrbitControls.js');

            this.initScene(THREE, STLLoader, OrbitControls, fileUrl);
        } catch (error) {
            console.error("Failed to load Three.js hardware preview:", error);
            this.el.innerHTML = '<div class="absolute inset-0 flex items-center justify-center text-red-500">Failed to load 3D engine.</div>';
        }
    },

    initScene(THREE, STLLoader, OrbitControls, url) {
        const width = this.el.clientWidth;
        const height = this.el.clientHeight;

        const scene = new THREE.Scene();
        scene.background = new THREE.Color(0xf3f4f6); // gray-100

        const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000);
        camera.position.set(200, 200, 200);

        const renderer = new THREE.WebGLRenderer({ antialias: true });
        renderer.setSize(width, height);
        this.el.innerHTML = "";
        this.el.appendChild(renderer.domElement);

        const controls = new OrbitControls(camera, renderer.domElement);
        controls.enableDamping = true;

        // Lights
        const ambientLight = new THREE.AmbientLight(0x404040, 2);
        scene.add(ambientLight);

        const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
        directionalLight.position.set(1, 1, 1);
        scene.add(directionalLight);

        // Loader
        const loader = new STLLoader();
        loader.load(url, (geometry) => {
            const material = new THREE.MeshPhongMaterial({ color: 0x6366f1, specular: 0x111111, shininess: 200 });
            const mesh = new THREE.Mesh(geometry, material);

            // Center the model
            geometry.computeBoundingBox();
            const center = new THREE.Vector3();
            geometry.boundingBox.getCenter(center);
            mesh.position.sub(center);

            scene.add(mesh);

            // Adjust camera to fit
            const size = geometry.boundingBox.getSize(new THREE.Vector3()).length();
            camera.position.set(size, size, size);
            camera.lookAt(0, 0, 0);
            controls.update();

            this.animate(renderer, scene, camera, controls);
        });

        window.addEventListener('resize', () => {
            const w = this.el.clientWidth;
            const h = this.el.clientHeight;
            renderer.setSize(w, h);
            camera.aspect = w / h;
            camera.updateProjectionMatrix();
        });
    },

    animate(renderer, scene, camera, controls) {
        requestAnimationFrame(() => this.animate(renderer, scene, camera, controls));
        controls.update();
        renderer.render(scene, camera);
    }
}
