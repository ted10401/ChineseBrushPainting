using UnityEngine;

public class AutoRotate : MonoBehaviour
{
    public Vector3 rotateSpeed;
    private Transform m_transform;

    private void Awake()
    {
        m_transform = transform;
    }

    private void Update()
    {
        m_transform.Rotate(rotateSpeed * Time.deltaTime);
    }
}
