Shader "Custom/Wave12"
{
    Properties
    {
        _BumpMap("BumpMap", 2D) = "Bump"{}
        _SmallWaveSpeed("SmallWave Speed", float) = 0.03
        _SpacPow("Spacular Power", float) = 2

        _Color("Color",Color) = (1,1,1,1)
    }

        SubShader
        {
            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
            LOD 200

            GrabPass{}


            CGPROGRAM
            #pragma surface surf WLight vertex:vert noambient noshadow 
            #pragma target 3.0

            sampler2D _BumpMap;
            float _SmallWaveSpeed;
            float3 _Color;

            sampler2D _GrabTexture;
            float _SpacPow;

            float dotData;

            struct Input
            {
                float2 uv_BumpMap;
                float3 worldRefl;
                float4 screenPos;
                float3 viewDir;
                INTERNAL_DATA
            };
            void vert(inout appdata_full v)
            {

                float4 res = sin((v.texcoord.x)*9 + _Time.y*2);
                res += sin((v.texcoord.y)* 9 + _Time.y*2);
                res += sin((v.texcoord.z)*10 + _Time.y*2);
                v.vertex.y += (sin(res))*3;
            }

            void surf(Input IN, inout SurfaceOutput o)
            {
                float4 nor1 = tex2D(_BumpMap, IN.uv_BumpMap + float2(_Time.y * _SmallWaveSpeed, 0));
                float4 nor2 = tex2D(_BumpMap, IN.uv_BumpMap - float2(_Time.y * _SmallWaveSpeed, 0));
                o.Normal = UnpackNormal((nor1 + nor2) * 0.5);
                //normal

                float4 sky = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, WorldReflectionVector(IN, o.Normal));
                float4 refrection = tex2D(_GrabTexture, (IN.screenPos / IN.screenPos.a).xy + o.Normal.xy * 0.03);
                //refrection

                dotData = pow(saturate(1 - dot(o.Normal, IN.viewDir)), 0.6);
                float3 water = lerp(refrection, sky, dotData).rgb;

                o.Albedo = water + _Color / 2;
            }

            float4 LightingWLight(SurfaceOutput s, float3 lightDIr, float3 viewDir, float atten)
            {
                float3 refVec = s.Normal * dot(s.Normal, viewDir) * 2 - viewDir;
                refVec = normalize(refVec);

                float spcr = lerp(0, pow(saturate(dot(refVec, lightDIr)),256), dotData) * _SpacPow;

                return float4(s.Albedo + spcr.rrr,1);
            }
            ENDCG



        }
            FallBack "Diffuse"
}
