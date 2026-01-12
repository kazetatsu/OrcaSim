using UnityEngine;

public class ShadowReceiver : MonoBehaviour
{
    MeshRenderer _renderer;
    [SerializeField] float radius;


    void OnDrawGizmos() {
        Gizmos.DrawWireSphere(Vector3.zero, radius);
    }


    void Start() {
        _renderer = GetComponent<MeshRenderer>();
    }


    void Update() {
        var sphereParams = new Vector4[1];
        sphereParams[0] = new Vector4(0f, 0f, 0f, radius*radius);
        _renderer.material.SetFloat("_SphereNum", 1f);
        _renderer.material.SetVectorArray("_SphereParams", sphereParams);
    }
}
