//
//  OpenGLESDemoView.m
//  OpenGLESStepByStep
//
//  Created by zyq on 14/12/2017.
//  Copyright © 2017 Mutsu. All rights reserved.
//

#import "OpenGLESDemoView.h"
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "CC3GLMatrix.h"

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

//const Vertex Vertices[] = {
//    {{1, -1, 0}, {1, 0, 0, 1}},
//    {{1, 1, 0}, {0, 1, 0, 1}},
//    {{-1, 1, 0}, {0, 0, 1, 1}},
//    {{-1, -1, 0}, {0, 0, 0, 1}}
//};

// Visible between near and far plane [-10, -4]
#define Z_AXIS (-1)

const Vertex Vertices[] = {
    {{1, -1, Z_AXIS}, {1, 0, 0, 1}},
    {{1, 1, Z_AXIS}, {0, 1, 0, 1}},
    {{-1, 1, Z_AXIS}, {0, 0, 1, 1}},
    {{-1, -1, Z_AXIS}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

@interface OpenGLESDemoView ()

@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint colorRenderBuffer;

@property (nonatomic, assign) GLuint colorSlot;
@property (nonatomic, assign) GLuint positionSlot;
@property (nonatomic, assign) GLuint projectionUniform;
@property (nonatomic, assign) GLuint modelViewUniform;


@end

@implementation OpenGLESDemoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVertexBufferObjects];
        [self render];
    }
    return self;
}


+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark -

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;
}


- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}


- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}


- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}


- (void)setupVertexBufferObjects {
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

#pragma mark - Shaders

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    // 1
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)compileShaders {
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
}

#pragma mark -

- (void)render {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = self.frame.size.height / self.frame.size.width;
    /*
     下述方法确定一个截头椎体，该方法的参数都是比例关系。
     比如left和right参数分别为-1和1时，表示截头椎体的near面左侧和右侧的x坐标分别为 {-1, 0} 和 {1, 0} （OpenGL坐标）
     比如left和right参数分别为-2和2时，表示截头椎体的near面左侧和右侧的x坐标分别为 {-1/2, 0} 和 {1/2, 0}
     
     top和bottom参数原理类似，但需要注意OpenGL使用的是归一化后的坐标，对于高宽不同的屏幕而言，{1, 0} 和 {0, 1} 到原点的物理距离并不相同
     
     near和far参数分别代表截头椎体near面和far面沿z轴到原点的距离。
     但需要注意的是near面之前和far面之后的区域在视觉上不可见，这一点可以通过调整vertex矩阵的z轴坐标来实验，比如z轴坐标为-3时不可见，为-11时也不可见。
     z轴的可见区间为[-10, -4]
     */
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-2*h andTop:2*h andNear:4 andFar:10];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    CC3GLMatrix *modelViewMat = [CC3GLMatrix matrix];
    /*
     沿z轴平移距离4
     */
    [modelViewMat populateFromTranslation:CC3VectorMake(0, 0, -4)];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelViewMat.glMatrix);
    
    // 1
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // Feed the correct values to the input variables for the vertex shader – the `Position` and `SourceColor` attributes.
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    // 3
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end

