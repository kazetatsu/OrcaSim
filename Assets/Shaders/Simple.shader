Shader "Custom/Simple"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BrightMap("Bright Map", 2D) = "white"
        _DarkMap("Dark Map", 2D) = "black"
        _Light("Light", Vector) = (0,-1,0)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            half _SphereNum;
            // x~z: center of sphere
            //  w : radius^2
            half4 _SphereParams[16];

            struct Attributes
            {
                float4 posOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 posHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                half3 posWorld : TEXCOORD1;
            };

            TEXTURE2D(_BrightMap);
            SAMPLER(sampler_BrightMap);

            TEXTURE2D(_DarkMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half3 _Light;
            //     float4 _BrightMap_ST;
            //     float4 _DarkMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.posHCS = TransformObjectToHClip(IN.posOS.xyz);
                OUT.uv = IN.uv;
                OUT.posWorld = TransformObjectToWorld(IN.posOS.xyz).xyz;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half s = 0;
                half cnt = 0.5;
                [unroll]
                for (int i = 0; i < 16; ++i) {
                    half3 x = IN.posWorld.xyz - _SphereParams[i].xyz;
                    half t = dot(x, _Light.xyz);
                    s += step(cnt, _SphereNum) * step(0, t) * step(dot(x,x) - t*t, _SphereParams[i].w);
                    cnt += 1;
                }
                s = step(0.5, s);

                half4 color = (1-s) * SAMPLE_TEXTURE2D(_BrightMap, sampler_BrightMap, IN.uv) + s * SAMPLE_TEXTURE2D(_DarkMap, sampler_BrightMap, IN.uv);
                return color * _BaseColor;
            }
            ENDHLSL
        }
    }
}
