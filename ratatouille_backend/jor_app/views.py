
from django.shortcuts import render
from rest_framework import viewsets, status
from .serializer import *
from .models import Recipe, Ingredient
from rest_framework import viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action

# Create your views here.
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_info(request):
    user = request.user
    return Response({
        "email": user.email,
        "username": user.username,
        "avatar": request.build_absolute_uri(user.avatar.url) if user.avatar else None
    })

class RecipeViewSet(viewsets.ModelViewSet):
    queryset = Recipe.objects.all().order_by('-created_at')
    serializer_class = RecipeSerializer

    @action(detail=False, methods=['get'])
    def by_category(self, request):
        category_name = request.query_params.get('category')
        if category_name:
            recipes = Recipe.objects.filter(category__name=category_name)
        else:
            recipes = Recipe.objects.all()
        serializer = self.get_serializer(recipes, many=True)
        return Response(serializer.data)

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

@api_view(['POST'])
def search_recipes(request):
    """
    Хэрэглэгчийн орцуудыг авч тухайн орцуудыг агуулсан recipe-г буцаах
    """
    selected_ingredients = request.data.get('ingredients', [])
    
    if not selected_ingredients:
        return Response({"recipes": []})

    recipes = Recipe.objects.filter(
        ingredients__name__in=selected_ingredients
    ).distinct()

    # 🔥 Энд request дамжуулна
    serializer = RecipeSerializer(recipes, many=True, context={'request': request})
    return Response(serializer.data)

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class IngredientViewSet(viewsets.ModelViewSet):
    queryset = Ingredient.objects.all()
    serializer_class = IngredientSerializer

class WishlistViewSet(viewsets.ModelViewSet):
    queryset = Wishlist.objects.all()
    serializer_class = WishlistSerializer
    permission_classes = [IsAuthenticated]

    # 🔥 1. GET /wishlist/my/  — Login хэрэглэгчийн wishlist авах
    @action(detail=False, methods=['get'])
    def my(self, request):
        wish = Wishlist.objects.filter(user=request.user)
        serializer = WishlistSerializer(wish, many=True, context={'request': request})
        return Response(serializer.data)

    # 🔥 2. POST /wishlist/add/ — Жор wishlist-д нэмэх
    @action(detail=False, methods=['post'])
    def add(self, request):
        recipe_id = request.data.get("recipe_id")

        if not recipe_id:
            return Response({"error": "recipe_id is required"}, status=400)

        # Давхардал шалгах
        exists = Wishlist.objects.filter(user=request.user, recipe_id=recipe_id).exists()
        if exists:
            return Response({"message": "Already added to wishlist"})

        # Шинэ wishlist item үүсгэх
        wishlist = Wishlist.objects.create(
            user=request.user,
            recipe_id=recipe_id
        )

        serializer = WishlistSerializer(wishlist, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    # 🔥 3. DELETE /wishlist/remove/<pk>/ — Устгах
    @action(detail=True, methods=['delete'])
    def remove(self, request, pk=None):
        try:
            item = Wishlist.objects.get(id=pk, user=request.user)
        except Wishlist.DoesNotExist:
            return Response({"error": "Not found"}, status=404)

        item.delete()
        return Response({"message": "Removed"}, status=204)

class NutritionViewSet(viewsets.ModelViewSet):
    queryset = Nutrition.objects.all()
    serializer_class = NutritionSerializer
    # class RecipeViewSet(viewsets.ModelViewSet):
#     queryset = Recipe.objects.all()
#     serializer_class = RecipeSerializer


# class CookingStepViewSet(viewsets.ModelViewSet):
#     queryset = CookingStep.objects.all()
#     serializer_class = CookingStepSerializer
